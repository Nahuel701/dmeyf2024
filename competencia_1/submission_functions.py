import os
import pandas as pd
import numpy as np
import lightgbm as lgb

def run_experiment(PARAM):
    """
    Runs a LightGBM training experiment and prepares submission files for Kaggle.
    """
    
    # Set working directory
    os.chdir(os.path.dirname(PARAM["input"]["dataset"]))

    # Load the dataset
    dataset = pd.read_csv(PARAM["input"]["dataset"])

    # Convert the class to binary {0,1}
    dataset["clase01"] = np.where(dataset["clase_ternaria"].isin(["BAJA+2", "BAJA+1"]), 1, 0)

    # Define the columns to use (excluding target columns)
    campos_buenos = [col for col in dataset.columns if col not in ["clase_ternaria", "clase01"]]

    # Define training set based on 'foto_mes'
    dataset["train"] = 0
    dataset.loc[dataset["foto_mes"].isin(PARAM["input"]["training"]), "train"] = 1

    # Create experiment folders
    os.makedirs(f"./{PARAM['experimento']}/", exist_ok=True)
    os.chdir(f"./{PARAM['experimento']}/")

    # Prepare LightGBM dataset
    dtrain = lgb.Dataset(
        data=dataset.loc[dataset["train"] == 1, campos_buenos].values,
        label=dataset.loc[dataset["train"] == 1, "clase01"].values
    )

    # Default parameters
    lgb_params = {
        "objective": "binary",
        "seed": PARAM["semilla_primigenia"]
    }

    # Check if finalmodel is present and update parameters accordingly
    if "finalmodel" in PARAM:
        lgb_params.update({
            "num_iterations": PARAM["finalmodel"]["num_iterations"],
            "learning_rate": PARAM["finalmodel"]["learning_rate"],
            "feature_fraction": PARAM["finalmodel"]["feature_fraction"],
            "min_data_in_leaf": PARAM["finalmodel"]["min_data_in_leaf"],
            "num_leaves": PARAM["finalmodel"]["num_leaves"],
            "max_bin": PARAM["finalmodel"]["max_bin"]
        })

    # Train the model (hyperparameters passed only if finalmodel exists)
    modelo = lgb.train(
        lgb_params,
        dtrain,
        num_boost_round=lgb_params.get("num_iterations", 100)  # Default num_boost_round if not provided
    )

    # Feature importance
    tb_importancia = modelo.feature_importance(importance_type='gain')
    feature_names = modelo.feature_name()
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'importance': tb_importancia
    })
    importance_df.to_csv("impo.txt", sep="\t", index=False)

    # Save the model
    modelo.save_model("modelo.txt")

    # Apply model to the future data
    dapply = dataset.loc[dataset["foto_mes"].isin(PARAM["input"]["future"])]

    # Predict
    prediccion = modelo.predict(dapply[campos_buenos].values)

    # Prepare submission table
    tb_entrega = dapply[["numero_de_cliente", "foto_mes"]].copy()
    tb_entrega["prob"] = prediccion

    # Save prediction file
    tb_entrega.to_csv("prediccion.txt", sep="\t", index=False)

    # Sort by probability in descending order
    tb_entrega = tb_entrega.sort_values(by="prob", ascending=False)

    # Create submission files for Kaggle
    cortes = range(10000, 14500, 500)
    for envios in cortes:
        tb_entrega["Predicted"] = 0
        tb_entrega.iloc[:envios, tb_entrega.columns.get_loc("Predicted")] = 1
        tb_entrega[["numero_de_cliente", "Predicted"]].to_csv(f"{PARAM['experimento']}_{envios}.csv", sep=",", index=False)

    print("\n\nLa generación de los archivos para Kaggle ha terminado\n")

def make_kaggle_submission(test_data, predictions, competition_name, message="My submission"):
    """
    Creates a submission file and submits it to a Kaggle competition.

    Parameters:
    - test_data: DataFrame containing test data (must include 'Id' or relevant identifier column).
    - predictions: Array or Series containing model predictions.
    - competition_name: The Kaggle competition name (string).
    - message: Submission message (optional, default: "My submission").
    """
    # Create submission DataFrame
    submission = pd.DataFrame({
        'Id': test_data['Id'],
        'Prediction': predictions
    })
    
    # Save submission as CSV
    submission_file = 'submission.csv'
    submission.to_csv(submission_file, index=False)
    print(f"Submission file saved as {submission_file}")

    # Submit the file using the Kaggle API
    kaggle_command = f'kaggle competitions submit -c {competition_name} -f {submission_file} -m "{message}"'
    os.system(kaggle_command)
    print(f"Submission for competition '{competition_name}' submitted with message: {message}")

def make_kaggle_submissions_from_directory(directory, competition_name, message="My submission"):
    """
    Uploads all CSV files from a given directory to a specified Kaggle competition.

    Parameters:
    - directory: Path to the directory containing CSV files.
    - competition_name: The Kaggle competition name (string).
    - message: Submission message (optional, default: "My submission").
    """
    # Ensure the directory exists
    if not os.path.exists(directory):
        print(f"Directory '{directory}' does not exist.")
        return

    # List all CSV files in the directory
    csv_files = [file for file in os.listdir(directory) if file.endswith('.csv')]
    
    if not csv_files:
        print(f"No CSV files found in '{directory}'.")
        return
    
    # Loop through each CSV file and submit to Kaggle
    for csv_file in csv_files:
        file_path = os.path.join(directory, csv_file)
        print(f"Submitting {csv_file} to competition '{competition_name}'")

        # Submit the file using the Kaggle API
        kaggle_command = f'kaggle competitions submit -c {competition_name} -f "{file_path}" -m "{message}"'
        os.system(kaggle_command)
        print(f"Submission of '{csv_file}' completed with message: {message}")

    print(f"\nAll CSV files in '{directory}' have been submitted to the competition '{competition_name}'.")

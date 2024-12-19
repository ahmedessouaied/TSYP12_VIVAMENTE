from fastapi import FastAPI, HTTPException
import pandas as pd
import joblib

# Initialize FastAPI app
app = FastAPI()

# Fixed file path where the CSV is stored after being fetched from Azure
FILE_PATH = "data/wearable.csv"

# Load the pre-trained model
try:
    model = joblib.load("model/wearable_device.pkl")
except FileNotFoundError:
    raise Exception("Model file not found. Ensure 'model/wearable_device.pkl' exists in the 'model' directory.")

@app.get("/predict/")
async def predict():
    """
    API endpoint to load a fixed CSV file, preprocess it, and return predictions.
    """
    try:
        # Load the CSV file from the fixed path
        df = pd.read_csv(FILE_PATH)

        # Validate if the DataFrame is empty
        if df.empty:
            raise HTTPException(status_code=400, detail="The CSV file is empty. Please ensure it contains valid data.")

        # Ensure the DataFrame matches the model's expected format
        if model.n_features_in_ != df.shape[1]:
            raise HTTPException(
                status_code=400,
                detail=f"CSV format mismatch. Expected {model.n_features_in_} features, but got {df.shape[1]}.",
            )

        # Make predictions
        predictions = model.predict(df)

        # Return predictions as a list
        return {"predictions": predictions.tolist()}

    except FileNotFoundError:
        raise HTTPException(status_code=400, detail=f"CSV file not found at the fixed path: {FILE_PATH}.")
    except pd.errors.EmptyDataError:
        raise HTTPException(status_code=400, detail="The specified file is not a valid CSV or is empty.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

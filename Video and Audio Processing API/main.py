import os
import subprocess
import time
import numpy as np
import shutil
import pandas as pd
from pydub import AudioSegment
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse, JSONResponse
from tempfile import NamedTemporaryFile
import mfcc
import egemaps
import boaw
from groq_stt import process_speech_to_text
from read_csv import load_features
from write_csv import save_features

# Paths for OpenFace
exe_openface = 'D:/OpenFace_2.2.0_win_x64/OpenFace_2.2.0_win_x64/FeatureExtraction.exe'
conf_openface = '-aus'  # Facial Action Units
folder_output = './visual_features'  # Output folder for facial features

# Folder to store temporary files for audio
TEMP_FOLDER = "temp_audio_files"
os.makedirs(TEMP_FOLDER, exist_ok=True)

# Ensure the output folder exists for visual features
if not os.path.exists(folder_output):
    os.makedirs(folder_output)

# FastAPI application
app = FastAPI()

# Header for visual feature files (FAUs)
header_output_file = ('name;frameTime;confidence;AU01_r;AU02_r;AU04_r;AU05_r;AU06_r;AU07_r;AU09_r;'
                      'AU10_r;AU12_r;AU14_r;AU15_r;AU17_r;AU20_r;AU23_r;AU25_r;AU26_r;AU45_r')  # 17 AU intensities

@app.post("/process-video-audio/")
async def process_video_audio(file: UploadFile = File(...)):
    # Create folder for storing uploads
    upload_folder = "./uploads"
    os.makedirs(upload_folder, exist_ok=True)
    
    # Save the uploaded video file
    video_path = os.path.join(upload_folder, file.filename)
    with open(video_path, "wb") as f:
        f.write(await file.read())
    
    # Extract audio from the video using pydub
    output_folder = os.path.join(upload_folder, "output")
    os.makedirs(output_folder, exist_ok=True)
    audio_output = os.path.join(output_folder, "audio.mp3")
    
    try:
        # Load the video file and export the audio
        audio = AudioSegment.from_file(video_path)
        audio.export(audio_output, format="mp3")
    except Exception as e:
        return {"error": f"Error extracting audio: {str(e)}"}

    # Now process the video file for facial feature extraction using OpenFace
    video_filename = os.path.splitext(file.filename)[0]  # Video file name without extension
    outfilename = os.path.join(folder_output, video_filename + '.csv')

    # Build OpenFace call
    openface_call = f'"{exe_openface}" {conf_openface} -f "{video_path}" -out_dir "{folder_output}"'
    
    try:
        # Run OpenFace to extract facial features
        result = subprocess.run(openface_call, check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(f"OpenFace output: {result.stdout.decode()}")
        print(f"OpenFace error (if any): {result.stderr.decode()}")
    except subprocess.CalledProcessError as e:
        return {"error": f"Error executing OpenFace: {str(e)}"}
    
    # Wait for OpenFace to finish processing the video and generate output file
    timeout = 600  # Set timeout for 10 minutes
    start_time = time.time()
    while not os.path.exists(outfilename):
        if time.time() - start_time > timeout:
            return {"error": f"Timeout: {outfilename} not created in {timeout} seconds."}
        time.sleep(0.5)
    
    # Check if the file exists in the output folder
    if not os.path.exists(outfilename):
        return {"error": f"Error: Output file {outfilename} not found. Skipping this file."}
    
    # Load features from OpenFace output
    try:
        features = load_features(outfilename, skip_header=True, skip_instname=False, delim=',')
        # Remove unnecessary columns (e.g., frame, face_id, confidence)
        features = np.delete(features, [0, 1, 4, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39], axis=1)
    except Exception as e:
        return {"error": f"Error loading features from {outfilename}: {str(e)}"}
    
    # Save the processed features into a CSV file
    try:
        save_features(outfilename, features, append=False, instname=video_filename, header=header_output_file, delim=';', precision=3)
    except Exception as e:
        return {"error": f"Error saving features to {outfilename}: {str(e)}"}
    
    # Process the audio file with the three scripts (mfcc, egemaps, boaw)
    try:
        mfcc_csv = mfcc.process_mfcc(audio_output)
        egemaps_csv = egemaps.process_egemaps(audio_output)
        boaw_csv = boaw.process_boaw(audio_output)
    except Exception as e:
        return JSONResponse(content={"error": f"Error processing audio features: {str(e)}"}, status_code=500)

    # Combine the audio CSVs into one final CSV
    final_audio_csv = combine_csvs(mfcc_csv, egemaps_csv, boaw_csv)

    # Save all CSV files
    audio_files = {
        "mfcc_csv": "mfcc_features.csv",
        "egemaps_csv": "egemaps_features.csv",
        "boaw_csv": "boaw_features.csv",
        "final_audio_csv": "final_audio_features.csv"
    }

    # Save the audio features CSVs
    mfcc_csv.to_csv(audio_files["mfcc_csv"], index=False)
    egemaps_csv.to_csv(audio_files["egemaps_csv"], index=False)
    boaw_csv.to_csv(audio_files["boaw_csv"], index=False)
    final_audio_csv.to_csv(audio_files["final_audio_csv"], index=False)

    # Return the results
    return {
        "message": "Processing successful",
        "audio_features": audio_files,
        "visual_features": outfilename
    }

def combine_csvs(mfcc_df, egemaps_df, boaw_df):
    # Merge the dataframes on common columns (you might need to adjust based on your data)
    combined_df = pd.concat([mfcc_df, egemaps_df, boaw_df], axis=1)
    return combined_df

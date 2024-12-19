import subprocess
import pandas as pd
import soundfile as sf
import librosa
import opensmile

def process_boaw(audio_path):
    # Process the audio file to extract LLDs
    y, sr = librosa.load(audio_path)
    wav_path = "audio.wav"
    sf.write(wav_path, y, sr)

    smile = opensmile.Smile(
        feature_set=opensmile.FeatureSet.eGeMAPSv02,
        feature_level=opensmile.FeatureLevel.LowLevelDescriptors,
    )

    # Extract LLDs
    r = smile.process_file(wav_path)

    # Convert the extracted LLDs into a DataFrame
    lld_df = pd.DataFrame(r)
    lld_df.reset_index(inplace=True)
    lld_df.rename(columns={"index": "id"}, inplace=True)
    lld_df["id"] = "audio1"

    # Save the LLD features to a CSV file
    lld_csv_path = "lld_features.csv"
    lld_df.to_csv(lld_csv_path, index=False)

    # Use openXBOW to generate Bag-of-Words (BoW) features
    bow_output_path = "bow_features.csv"
    subprocess.run([
        "java", "-jar", "openXBOW.jar",  # Path to openXBOW.jar
        "-i", lld_csv_path,              # Path to the LLD CSV
        "-o", bow_output_path,           # Output path for BoW features
        "-size", "500"                   # BoW feature size
    ])
    
    # Check if BoW features were generated successfully
    try:
        bow_df = pd.read_csv(bow_output_path)
    except FileNotFoundError:
        print(f"Error: {bow_output_path} not found. Ensure openXBOW ran successfully.")
        return None

    return bow_df

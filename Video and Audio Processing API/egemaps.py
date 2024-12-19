import opensmile
import pandas as pd
import soundfile as sf

def process_egemaps(audio_path):
    # Initialize openSMILE for eGeMAPSv02 features
    smile = opensmile.Smile(
        feature_set=opensmile.FeatureSet.eGeMAPSv02,
        feature_level=opensmile.FeatureLevel.Functionals,
    )
    
    # Process the audio file
    features = smile.process_file(audio_path)
    
    # Convert to DataFrame
    egemaps_df = pd.DataFrame(features)
    return egemaps_df

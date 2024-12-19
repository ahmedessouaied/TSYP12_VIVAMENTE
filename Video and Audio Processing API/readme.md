
# Video and Audio Processing API

This project provides a FastAPI service to process both video and audio files. The service extracts facial features from video files and audio features from audio files, saving the results into CSV files. It integrates with external libraries such as OpenFace for facial feature extraction, and processes audio files using MFCC, eGeMAPS, and BoAW for audio feature extraction.


## Features

- **Facial Feature Extraction**: Extracts facial features (Action Units) from videos using OpenFace.
- **Audio Feature Extraction**: Processes audio files to extract features using MFCC, eGeMAPS, and BoAW.
- **CSV Output**: Saves the extracted features in CSV format for both audio and visual data.
- **FastAPI Integration**: Provides an API endpoint for video and audio processing.

## Requirements

- Python 3.8+
- FastAPI
- Pydub
- Pandas
- Numpy
- subprocess
- External libraries: `mfcc`, `egemaps`, `boaw`, `groq_stt`, `read_csv`, `write_csv`
- OpenFace executable for facial feature extraction

## Installation

1. Install Python dependencies:
   ```bash
   pip install fastapi pydub pandas numpy
   ```

2. Download and install OpenFace for facial feature extraction:
   - Ensure that `FeatureExtraction.exe` is available and update the `exe_openface` path in the code to point to the correct location.

3. Install required audio libraries:
   ```bash
   pip install pydub
   ```

4. Set up necessary file paths, including the OpenFace executable and folder paths in the script.

## API Usage

### Endpoint: `/process-video-audio/`

This endpoint processes both video and audio files to extract features.

#### Request

- **Method**: `POST`
- **Body**: The video file to process, sent as a `multipart/form-data` request.
  - **file**: Video file (any common video format such as `.mp4`, `.avi`).

#### Response

The API will return the following fields:

- **message**: A success message indicating that the processing was successful.
- **audio_features**: Paths to the audio feature CSV files (MFCC, eGeMAPS, BoAW, and final combined).
- **visual_features**: Path to the visual feature CSV file containing extracted facial features.

### Example

To process a video file:

```bash
curl -X 'POST'   'http://localhost:8000/process-video-audio/'   -F 'file=@/path/to/your/video.mp4'
```

#### Sample Response:

```json
{
  "message": "Processing successful",
  "audio_features": {
    "mfcc_csv": "mfcc_features.csv",
    "egemaps_csv": "egemaps_features.csv",
    "boaw_csv": "boaw_features.csv",
    "final_audio_csv": "final_audio_features.csv"
  },
  "visual_features": "./visual_features/video_filename.csv"
}
```

## Notes

- Ensure OpenFace is correctly installed and the path to `FeatureExtraction.exe` is set in the code.
- The `process-video-audio/` endpoint processes video and audio in sequence, so ensure the video file size is manageable for the time constraints of the processing.

import os
import subprocess
from groq import Groq  

# Groq API details
MAX_FILE_SIZE_MB = 25  # Groq API file size limit

def preprocess_audio_ffmpeg(input_path, output_path):
    """
    Preprocess the audio file using FFmpeg to downsample to 16,000 Hz mono.
    Args:
        input_path (str): Path to the input audio file.
        output_path (str): Path to save the processed audio file.
    """
    try:
        subprocess.run(
            [
                "ffmpeg",
                "-i", input_path,
                "-ar", "16000",
                "-ac", "1",
                "-map", "0:a:",
                output_path
            ],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"FFmpeg preprocessing failed: {e.stderr.decode()}")

def process_speech_to_text(audio_path, model="whisper-large-v3-turbo"):
    """
    Process audio for speech-to-text using Groq's SDK.
    Args:
        audio_path (str): Path to the audio file.
        model (str): Whisper model to use.

    Returns:
        str: Transcription text or error message.
    """
    api_key="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"
    # Preprocess audio with FFmpeg
    processed_audio_path = os.path.splitext(audio_path)[0] + "_processed.wav"
    preprocess_audio_ffmpeg(audio_path, processed_audio_path)

    # Check file size
    file_size_mb = os.path.getsize(processed_audio_path) / (1024 * 1024)
    print(f"Processed audio file size: {file_size_mb:.2f} MB")
    if file_size_mb > MAX_FILE_SIZE_MB:
        return "Error: The audio file is too large, even after preprocessing."

    # Initialize the Groq client
    client = Groq(api_key=api_key)

    # Open the processed audio file
    with open(processed_audio_path, "rb") as file:
        # Send the audio file for transcription
        transcription = client.audio.transcriptions.create(
            file=(processed_audio_path, file.read()),  # Audio file content
            model=model,  # Use the specified Whisper model
            prompt="Turn this audio into text",  # Optional
            response_format="json",  # Optional
            language="en",  # Optional
            temperature=0.0  # Optional
        )

    return transcription.text if transcription else "Transcription failed."


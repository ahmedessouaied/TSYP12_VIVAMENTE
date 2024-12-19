from azure.storage.blob import BlobServiceClient

def download_blob(connection_string, container_name, blob_name, download_path):
    # Create the blob service client
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    
    # Get the container client
    container_client = blob_service_client.get_container_client(container_name)
    
    # Download the blob
    with open(download_path, "wb") as file:
        blob_client = container_client.get_blob_client(blob_name)
        file.write(blob_client.download_blob().readall())


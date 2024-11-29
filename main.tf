provider "google" {
  credentials = file("/home/kparabrahmammsc/my.json")  # Path to your service account key
  project     = "fiery-spider-442905-u4"  # Your actual project ID
  region      = "us-central1"  # Replace with your desired region
}

resource "google_storage_bucket" "my_bucket" {
  name     = "fiery-spider-442905-u4-bucket-20241129"  # Use a unique name, e.g., project ID + date
  location = "US-East1"  # Or your desired location
}


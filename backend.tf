terraform {
  backend "gcs" {
    bucket  = "tfstatetestjjgp"
    prefix  = "terraform/state"
  }
}
# Regula Document Reader (.NET MAUI version)
Document Reader allows you to read various kinds of identification documents, passports, driving licenses, ID cards, etc. All processing is performed completely offline on your device.

## How to build demo application
1. Get the trial license at client.regulaforensics.com. The license creation wizard will guide you through the necessary steps.
2. Get the trial database at client.regulaforensics.com/customer/databases.
2. Clone current repository: `git clone https://github.com/regulaforensics/Xamarin-DocumentReader.git`.
4. Place the license at `Resources/Raw/regula.license`. 
5. Place the database at `Platforms/Android/Assets/Regula/db.dat` and `Resources/Raw/db.dat`. 
6. Open the project and run it.

## Documentation
You can find documentation on API [here](https://docs.regulaforensics.com/develop/doc-reader-sdk/mobile/).

## Additional information
If you have any technical questions, feel free to [contact](mailto:support@regulaforensics.com) us or create issues [here](https://github.com/regulaforensics/Xamarin-DocumentReader/issues).

## Troubleshooting license issues
If you have issues with license verification when running the application, please verify that next is true:
1. The OS, which you use, is specified in the license (e.g., Android and/or iOS).
2. The license is valid (not expired).
3. The date and time on the device, where you run the application, are valid.
4. You use the latest release version of the Document Reader SDK.
5. You placed the license into the correct folder.

# Regula Face SDK (.NET MAUI version)
Face SDK is a framework that is used for face matching, recognition, and liveness detection.

## How to build the demo application
1. Download or clone this repository using the command `git clone https://github.com/regulaforensics/Xamarin-FaceSDK.git`.
2. Open the project and run it.

## How to use offine match
1. Place a license that supports offline match at `Resources/Raw/regula.license`.
2. Change android and iOS bundle id if required by your license. 
For android in `Platforms/Android/AndroidManifest.xml` change `manifest.package`.
For iOS in `Platforms/iOS/Info.plist` change `CFBundleIdentifier`.
3. Change core in `FaceSample.csproj`:
Replace `Xamarin.FaceCore.Basic.iOS` with `Xamarin.FaceCore.Match.iOS`.
Replace `Xamarin.FaceCore.Basic.Droid` with `Xamarin.FaceCore.Match.Droid`.
Adjust versions of changed packages if needed, beware that versions of basic and match cores may be different. You can always check them at [nuget.org](https://www.nuget.org/packages).
4. Turn off the internet and run the app.

## Documentation
You can find documentation on API [here](https://docs.regulaforensics.com/develop/face-sdk/mobile/).

## Additional information
If you have any technical questions, feel free to [contact](mailto:support@regulaforensics.com) us or create issues [here](https://github.com/regulaforensics/Xamarin-FaceSDK/issues).

kalimba
=======

puredata (libpd) for unity mobile (ios,android)

Kalimba is a puredata (libpd) binding for Unity, mainly targeting mobile platforms (Unity's iOS, Android export). For testing and debugging purpose it is possible to connect via tcp and use pd during "editor-play" mode.

Features
========
* Android, iOS: vanilla libpd
* Android: on-the-fly extraction from apk file (eg. content from StreamingAssets/pd)
* Android: ogg streaming/playback
* Android: midi parsing (cyclone)

Example usage
=============
	public class AudioTest : MonoBehaviour
	{
		void Start ()
		{
			KalimbaPd.Init();
			KalimbaPd.OpenFile("kalimbaTest.pd", "pd");
		}

		void OnGUI ()
		{
			if (GUI.Button (new Rect (10, 10, 100, 50), "sine_on")) 
			{
				KalimbaPd.SendBangToReceiver("sine_on");
			}
		}
	}

How to use
==========
* The directory "unity3d" contains a example project containing a simple pd file and some unity gui buttons to control pd.
* "ios-libpd" contains all the iOS specific source code. There is a README.txt in this directory that explains how to add it to our xcode project.
* "android-libpd" contains all necessary files to build pd jni for Android.
* "android-exampleapp" contains all necessary files to build the custom Unity-Android activity.

Known issues
============
* latency issue on Android
* missing ogg streaming and midi parsing on iOS
* missing automatic workflow to add files (eg. pd, ogg) from Unity to XCode project

Thanks to
=========
* puredata & community - For creating a great tool.
* dreamfab - For funding and publishing Tridek which is the first game that will use kalimba.
* Bit Barons & Filippo Beck Peccoz - For being willing to create a game with real interactive audio.

License
=======
Same license (bsd like) as pd and pd related things.

Kalimba specific links
======================
* http://blog.tridek.com/post/31459621189/the-composers-new-role-in-game-development
* http://blog.tridek.com/post/29834155461/using-libpd-with-unity3d-on-mobile-devices-part-1

Software/Games using kalimba
============================
* Boinkss - http://www.noisetoysound.org.uk/boinkss.html
* SonicScan Touch - http://www.noisetoysound.org.uk/sonicscan.html

General puredata links
======================
* https://github.com/libpd - original source (pd, ios binding, android binding)
* http://puredata.info/ - pure data main page
* https://github.com/Magicolo/uPD - A relatively complete alternative to Unity's audio engine using Pure Data and LibPD.

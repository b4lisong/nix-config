{
  lib,
  stdenv,
}: let
  # Include your configurations directly here
  profileSet = ''
    [Mapping Speakers]
    device-strings = hw:%f,0
    paths-output = t2-speakers
    channel-map = front-left,front-right,rear-left,rear-right
    direction = output

    [Mapping BuiltinMic]
    device-strings = hw:%f,1
    paths-input = t2-builtin-mic
    channel-map = aux0,aux1,aux2
    direction = input

    [Mapping Headphones]
    device-strings = hw:%f,2
    paths-output = t2-headphones
    channel-map = left,right
    direction = output

    [Mapping HeadsetMic]
    device-strings = hw:%f,3
    paths-input = t2-headset-mic
    channel-map = mono
    direction = input

    [Profile Default]
    description = Default Profile
    output-mappings = Speakers Headphones
    input-mappings = BuiltinMic HeadsetMic
  '';

  t2SpeakersConf = ''
    [General]
    type = speaker
    priority = 100
    description-key = analog-output-speaker
  '';

  t2BuiltinMicConf = ''
    [General]
    type = mic
    priority = 100
    description-key = analog-input-microphone-internal
  '';

  t2HeadphonesConf = ''
    [General]
    type = headphones
    priority = 200
    description-key = analog-output-headphones

    [Jack Codec Output]
    required = any
  '';

  t2HeadsetMicConf = ''
    [General]
    type = headset
    priority = 200
    description-key = analog-input-microphone-headset

    [Jack Codec Output]
    required = any
  '';
in
  stdenv.mkDerivation {
    pname = "apple-t2-pipewire-config";
    version = "1.0";

    src = null;
    dontBuild = true;
    dontConfigure = true;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/alsa-card-profile/mixer/profile-sets/
      mkdir -p $out/share/alsa-card-profile/mixer/paths/

      # Write the profile set configuration
      echo "${profileSet}" > $out/share/alsa-card-profile/mixer/profile-sets/apple-t2x4.conf

      # Write the path configurations
      echo "${t2SpeakersConf}" > $out/share/alsa-card-profile/mixer/paths/t2-speakers.conf
      echo "${t2BuiltinMicConf}" > $out/share/alsa-card-profile/mixer/paths/t2-builtin-mic.conf
      echo "${t2HeadphonesConf}" > $out/share/alsa-card-profile/mixer/paths/t2-headphones.conf
      echo "${t2HeadsetMicConf}" > $out/share/alsa-card-profile/mixer/paths/t2-headset-mic.conf
    '';

    meta = with lib; {
      description = "Custom PipeWire configuration for Apple T2 audio (T2x4)";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
    };
  }

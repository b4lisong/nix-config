{pkgs, ...}: 
    (pkgs.stdenvNoCC.mkDerivation (final: {
       name = "brcm-firmware";
       src = ./firmware/brcm;
       installPhase = ''
         mkdir -p $out/lib/firmware/brcm
         cp ${final.src}/* "$out/lib/firmware/brcm"
       '';
     }))

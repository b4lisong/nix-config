{lib}: {
  username = "balisong";
  userfullname = "JL";
  useremail = "5397809+b4lisong@users.noreply.github.com";
  # TODO: define networking
  #networking = import ./networking.nix {inherit lib;};
  # generated by `mkpasswd -m scrypt`
  initialHashedPassword = "$7$CU..../....lhw67TWNfcB5X/eHgzNdh/$anRfBntKkc9HXPxcT.qpM2a4.DbcweehHgyKX4naui6";
  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9 balisong"
  ];
}
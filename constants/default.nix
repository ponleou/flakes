{
  pleiades = {
    alcyone = {
      drive = {
        root = "media";
        main = "pleiades";
        storage = "store";
      };
      networking = {
        staInterface = "wlp1s0u1";
        apInterface = "wlp1s0u1_ap";
        apMacAddress = "7A:C0:3C:D8:4A:E6";
        ethInterface = "end0";
      };
      forgejo = {
        port = 3000;
        anubisPort = 3001;
      };
    };
  };
}

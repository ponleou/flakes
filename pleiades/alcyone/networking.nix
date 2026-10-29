{
  lib,
  pkgs,
  constants,
  ...
}:
let
  networking = constants.alcyone.networking;
in
{
  environment.systemPackages = with pkgs; [
    iw
    bind # for nslookup
  ];

  # creating a wifi wireless repeater (STA/AP)
  systemd.services = {
    "create-${networking.apInterface}-interface" = {
      description = "Create virtual AP interface for ${networking.staInterface}";
      requires = [ "sys-subsystem-net-devices-${networking.staInterface}.device" ];
      after = [ "sys-subsystem-net-devices-${networking.staInterface}.device" ];
      before = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig.ConditionPathExists = "!/sys/class/net/${networking.apInterface}";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.iw}/bin/iw dev ${networking.staInterface} interface add ${networking.apInterface} type managed addr ${networking.apMacAddress}";
      };
    };

    hostapd = {
      # on the rpi4, network manager cant connect when hostapd is up, it seems to differ from device to device
      wants = [ "network-online.target" ];
      after = lib.mkAfter [ "network-online.target" ];

      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = lib.mkForce "5";
      };
    };
  };

  services = {
    hostapd = {
      enable = true;

      radios.${networking.apInterface} = {
        band = "5g";
        # NOTE: the current wifi adapter cannot do sta/ap with sta and ap on different channels
        channel = 36; # or 149 (with 80 MHz width)
        countryCode = "US";
        driver = "nl80211";

        wifi4 = {
          enable = true;
          capabilities = [
            "LDPC"
            "HT40+"
            "HT40-"
            "SHORT-GI-20"
            "SHORT-GI-40"
            "TX-STBC"
            "RX-STBC1"
            "MAX-AMSDU-7935"
          ];
        };

        wifi5 = {
          enable = true;
          operatingChannelWidth = "80";
          capabilities = [
            "MAX-MPDU-11454"
            "RXLDPC"
            "SHORT-GI-80"
            "TX-STBC-2BY1"
            "SU-BEAMFORMEE"
            "MU-BEAMFORMEE"
            "RX-ANTENNA-PATTERN"
            "TX-ANTENNA-PATTERN"
            "RX-STBC-1"
            "BF-ANTENNA-4"
            "MAX-A-MPDU-LEN-EXP7"
          ];
        };

        wifi6 = {
          enable = true;
          operatingChannelWidth = "80";
        };

        networks.${networking.apInterface} = {
          ssid = "Skyfi-rpi";
          authentication = {
            mode = "wpa2-sha256";
            wpaPasswordFile = "/etc/hostapd/pass"; # TODO: create password file
          };
          settings = {
            wpa_key_mgmt = lib.mkForce "WPA-PSK WPA-PSK-SHA256";
            rsn_pairwise = "CCMP";
            ieee80211w = 1;
            max_num_sta = 16;
            wmm_enabled = 1;
            basic_rates = "60 120 240";
          };
        };

        settings = {
          beacon_int = 100;
          dtim_period = 1;
          he_bss_color = 37;

          # NOTE: these vht/he settings seem to pair with the channel
          vht_oper_centr_freq_seg0_idx = 42;
          he_oper_centr_freq_seg0_idx = 42;
        };
      };
    };

    # dhcp and dns server
    dnsmasq = {
      enable = true;
      settings = {
        interface = [
          "${networking.apInterface}"
          "${networking.ethInterface}"
        ];
        domain-needed = true;
        dhcp-range = [
          "interface:${networking.apInterface},10.1.2.50,10.1.2.254,255.255.255.0,12h"
          "interface:${networking.ethInterface},10.1.1.50,10.1.1.254,255.255.255.0,12h"
        ];

        no-resolv = true; # resolv has the dns server from dhcp
        server = [
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
    };

    # mdns client
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        addresses = true;
      };
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      unmanaged = [
        "interface-name:${networking.apInterface}"
        "interface-name:${networking.ethInterface}"
        "interface-name:wlan0"
      ];

      # use the local dnsmasq's dns server as main (ones provided by dhcp are still there)
      insertNameservers = [ "127.0.0.1" ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [
        "${networking.ethInterface}"
        "${networking.apInterface}"
      ];
      interfaces.${networking.staInterface} = {
        allowedTCPPorts = [
          22
          53
        ]; # ssh, dns
        allowedUDPPorts = [
          68
          53
          5353
        ]; # dhcp res, dns, mdns (for hostname discovery)
      };
    };

    nat = {
      enable = true;
      externalInterface = "${networking.staInterface}";
      internalInterfaces = [
        "${networking.ethInterface}"
        "${networking.apInterface}"
      ];
    };

    # assigning interfaces static ip
    interfaces = {
      ${networking.ethInterface}.ipv4.addresses = [
        {
          address = "10.1.1.1";
          prefixLength = 24;
        }
      ];

      ${networking.apInterface}.ipv4.addresses = [
        {
          address = "10.1.2.1";
          prefixLength = 24;
        }
      ];
    };
  };
}

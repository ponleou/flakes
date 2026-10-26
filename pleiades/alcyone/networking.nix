{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    iw
    hostapd
    dnsmasq
  ];

  # creating a wifi wireless repeater
  systemd.services.create-wlp1s0u1_ap-interface = {
    description = "Create virtual AP interface for wlp1s0u1";
    requires = [ "sys-subsystem-net-devices-wlp1s0u1.device" ];
    after = [ "sys-subsystem-net-devices-wlp1s0u1.device" ];
    before = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iw}/bin/iw dev wlp1s0u1 interface add wlp1s0u1_ap type managed addr 7A:C0:3C:D8:4A:E6";
    };
  };

  systemd.services.hostapd.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = lib.mkForce "5";
  };

  services = {
    hostapd = {
      enable = true;

      radios.wlp1s0u1_ap = {
        band = "5g";
        channel = 149; # or 36 (with 80 MHz width)
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

        networks.wlp1s0u1_ap = {
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
          vht_oper_centr_freq_seg0_idx = 155;
          he_oper_centr_freq_seg0_idx = 155;
        };
      };
    };

    # dhcp and dns server
    dnsmasq = {
      enable = true;
      settings = {
        interface = "wlp1s0u1_ap";
        domain-needed = true;
        dhcp-range = [
          "10.1.2.50,10.1.2.254,255.255.255.0,12h"
        ];
        server = [
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      unmanaged = ["interface-name:wlp1s0u1_ap" "interface-name:end0"];
    };

    # assigning interfaces static ip
    interfaces = {
      end0.ipv4.addresses = [
        {
          address = "10.1.1.1";
          prefixLength = 24;
        }
      ];

      wlp1s0u1_ap.ipv4.addresses = [
        {
          address = "10.1.2.1";
          prefixLength = 24;
        }
      ];
    };
  };
}

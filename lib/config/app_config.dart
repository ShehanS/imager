import '../models/news_paper.dart';

class AppConfig {
  static String host = "35.223.179.211";
  static String username = "gayan.dissanayake";
  static String password = "";
  static String ftp_path = "/home/gayan.dissanayake/ncinga-images/";
  static String ftp_test_path = "/home/gayan.dissanayake/imager-test/";
  static String local_dir = "/storage/emulated/0/DCIM/image-source";
  static String shell_script_path =
      "sudo /home/gayan.dissanayake/adfetch/script/";
  static String private_key = """
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEAvxcMoSqvRsw1tF/WF874FhBqzJTKcGvRLk7nKvBWo7ARqNBCJl3N
xx6yv74wwjYPJz0HNuXYPp8fwP2VQUp/+m8mHT8GvJKnhQ/W7mHImN7SZPFlOjxhMyLRfg
0cw1dc9jv3E2RbNTFz0Nql9nbUlPqrtr038bjwlU55FDuEEyCxpOuWAHbcAcm72b4EXNRM
hV0YD6K9SyDc48XPEOXRg0rToZyhEHHis+nIWS4TG1BynrB9gOz9W7UFVJCvNcqg1RxdHZ
j/0hJt3yZHVCfxeFrK/kejqHreaBrS4sIYiIx/9USJEtI+LxSVPwJgtvlA+lf7eaRVJD7a
IzVT1AATuQAAA9h9VOV3fVTldwAAAAdzc2gtcnNhAAABAQC/FwyhKq9GzDW0X9YXzvgWEG
rMlMpwa9EuTucq8FajsBGo0EImXc3HHrK/vjDCNg8nPQc25dg+nx/A/ZVBSn/6byYdPwa8
kqeFD9buYciY3tJk8WU6PGEzItF+DRzDV1z2O/cTZFs1MXPQ2qX2dtSU+qu2vTfxuPCVTn
kUO4QTILGk65YAdtwBybvZvgRc1EyFXRgPor1LINzjxc8Q5dGDStOhnKEQceKz6chZLhMb
UHKesH2A7P1btQVUkK81yqDVHF0dmP/SEm3fJkdUJ/F4Wsr+R6Ooet5oGtLiwhiIjH/1RI
kS0j4vFJU/AmC2+UD6V/t5pFUkPtojNVPUABO5AAAAAwEAAQAAAQBzNRpQMMPsE0JttToG
sKmx48QAA9TpYpeDK98DbFNP7N84wBahuvxNiJyMLcaH0L/iEFFBL+HoH1etqzVJX/k4q7
p294DAQErvVlVm811VjUGbyk4VhkGz6tITBSTKQOmzKwQTlPXIZEBHMwvMRGh2SYstaXdJ
LQ8fdWhaYmeGf6x5QUOLGzl17CGGBiQl6prz8BnI/mrbGyPLh8wU5KOg+E2xF2vunCQ1dW
yzHHWkxKt6EInKVaokaVwzceRQMh18nOw8QmU79QZadAZKEqdkC8OLPuf+k/r6dk1LnNIN
25gDuKzXnzjqi7ByyD9zzJqEbAk7YMf7EBnFLVWRPFxhAAAAgQCzBmQ1+FNuiMh/UhwPjZ
uyaYkip731cjVLwOu6mOkEmYnt+dghQWS++vsfU+tCZh/drOZhdr0T/q/tRpLURoTEQA/Z
yY40Wt6QHMxlywZXOJNkuUrs1BA/YrXleLa2XdtC30/fOtB6hmohtiztPU8n+iZ4HsXKP4
0FEBJalVLM4gAAAIEA6iYKwkZfXjnI6Bl9uepjGAwahrHr0enmJJIJRrIqdaqOqDSI2S4/
538cm3rZE7w/alU6vNQGCKttezvoyjcIoIOpUXt2ui+ncCW5bCatyVa7knDW9v5ElndyRN
LyQq95bwmwrgrS41SMLQg2swfQL5pDhEL/Hn+BhXpoePrDsqMAAACBANDsT50ROtz9Z/ol
ETaEYmAS+ZpGLmt/4BKEJWReNXjwp/a0GzZMm0lOp70Cwz11ZCt9RC0Jyg5iTQeaZ5J26l
eCJ/yYI5wnP+dIxzH1E9SIv3aaLM4PrI1n0A2BT54B1HdlsKu01QEe0WtivrS1CwQZfl/X
QsMVk/0vGoim16HzAAAAHGdheWFuLmRpc3NhbmF5YWtlQG5jaW5nYS5uZXQBAgMEBQY=
-----END OPENSSH PRIVATE KEY-----

""";

  static List<NewsPaper> newspapers = [
    NewsPaper("hitad", "HitAd", "1"),
    NewsPaper("lahipita", "Lahipita", "2"),
    NewsPaper("veera", "Veera", "3")
  ];
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RGiesecke.DllExport;
using System.Runtime.InteropServices;
using System.Net;
using System.Net.NetworkInformation;
using System.IO;

namespace Rx_VersionCheck_Lib
{
    public static class VersionCheck
    {
        static string Version = "";
        static string[] servers;
        static Dictionary<String, Int32> pings = new Dictionary<string, int>();
        static Object lockObj = new Object();
        static int doubleServerCorrection;
        static string finishedIds, polledIds;

        [DllExport("PingIp", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string PingIp([MarshalAs(UnmanagedType.LPWStr)] string IpString)
        {
            string tmpIp = "500";

            try
            {
                IPAddress tmpIpAd = IPAddress.Parse(IpString);
                PingReply Result = new Ping().Send(tmpIpAd, 500);
                if (Result.Status == IPStatus.Success)
                    return String.Format("{0:d}", Result.RoundtripTime);
            }
            catch (Exception E){}

            return tmpIp;
        }

        [DllExport("StartPingAll", CallingConvention = CallingConvention.StdCall)]
        public static void StartPingAll([MarshalAs(UnmanagedType.LPWStr)] string ServersString)
        {
            servers = ServersString.Split(',');

            if (servers == null)
                servers = new string[] { ServersString };

            StartPinging();
        }

        private static void StartPinging()
        {
            doubleServerCorrection = 0;
            pings.Clear();
            finishedIds = "";
            polledIds = "";
            foreach (string server in servers)
            {
                try
                {
                    Ping locPing = new Ping();
                    locPing.PingCompleted += new PingCompletedEventHandler(pingObj_PingCompleted);
                    string[] tmpStr = server.Split('-');
                    locPing.SendAsync(tmpStr[0], 500, tmpStr[1]);
                }
                catch (Exception e)
                {
                    log("\r\n\r\n" + e.ToString() + "\r\n\r\n");
                }
            }
        }

        static void pingObj_PingCompleted(object sender, PingCompletedEventArgs e)
        {
            lock (lockObj)
            {
                if (finishedIds != "")
                    finishedIds += "," + e.UserState;
                else
                    finishedIds += e.UserState;

                if (!pings.ContainsKey(e.Reply.Address.ToString()))
                {
                    pings.Add(e.Reply.Address.ToString(), (Int32)e.Reply.RoundtripTime);
                }
                else
                {
                    doubleServerCorrection++;
                }
            }
        }

        private static Int32 p(string IpString)
        {
            Int32 tmpIp = 500;
            using (Ping pingObj = new Ping())
            {
                PingReply Result = pingObj.Send(IPAddress.Parse(IpString), 500);
                if (Result.Status == IPStatus.Success)
                    return (Int32)Result.RoundtripTime;
            }
            return tmpIp;
        }

        private static void log(string text)
        {
            File.AppendAllText("NativeLog.txt", DateTime.Now + "| " + text + Environment.NewLine);
        }

        [DllExport("GetPingStatus", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.I4)]
        public static int GetPingStatus()
        {
            return pings.Count + doubleServerCorrection;
        }

        [DllExport("GetPingedIDs", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string GetPingedIDs()
        {
            string retIds = "";
            //log("4. GetPingStatus - Polling request returns: " + (pings.Count + doubleServerCorrection));
            lock (lockObj)
            {
                if (polledIds == "")
                {
                    retIds = finishedIds;
                    polledIds = finishedIds;
                }
                else
                {
                    retIds = finishedIds.Replace(polledIds, "");
                    polledIds = finishedIds;
                }
            }
            return retIds;
        }

        [DllExport("GetPingFor", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.I4)]
        public static Int32 GetPingFor([MarshalAs(UnmanagedType.LPWStr)] string Ip)
        {
            if (pings.ContainsKey(Ip))
            {
                return pings[Ip];
            }
            else
            {
                return -1;
            }
        }

        [DllExport("NonAsyncReadVersion", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string NonAsyncReadVersion([MarshalAs(UnmanagedType.LPWStr)] String VersionInfoURL)
        {
            WebClient Client = new WebClient();
            byte[] raw = Client.DownloadData(VersionInfoURL);
            string webData = System.Text.Encoding.UTF8.GetString(raw);
            return webData;
        }

        [DllExport("OpenWebsiteAndExit", CallingConvention = CallingConvention.StdCall)]
        public static void OpenWebsiteAndExit([MarshalAs(UnmanagedType.LPWStr)] String SiteURL)
        {
            System.Diagnostics.Process.Start(SiteURL);
            Environment.Exit(0);
        }

        [DllExport("PollVersion", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string PollVersion()
        {
            return Version;
        }

        [DllExport("StartFindVersion", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string StartFindVersion([MarshalAs(UnmanagedType.LPWStr)] String VersionInfoURL)
        {
            StartDownloadData(VersionInfoURL);
            return "";
        }

        public static void StartDownloadData(string URL)
        {
            WebClient Client = new WebClient();
            Client.DownloadDataCompleted += DownloadDataCompleted;
            Uri URI = null;
            if (Uri.TryCreate(URL, UriKind.Absolute, out URI))
                Client.DownloadDataAsync(URI);
        }

        static void DownloadDataCompleted(object sender, DownloadDataCompletedEventArgs e)
        {
            if (e.Error == null && !e.Cancelled)
            {
                byte[] raw = e.Result;
                string webData = System.Text.Encoding.UTF8.GetString(raw);
                Version = webData;
            }
        }
    }
}

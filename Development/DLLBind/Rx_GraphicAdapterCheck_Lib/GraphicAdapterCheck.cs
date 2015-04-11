using System;
using System.Collections.Generic;
using System.Management;
using System.Runtime.InteropServices;
using System.Text;
using RGiesecke.DllExport;

namespace Rx_GraphicAdapterCheck_Lib
{
   internal static class GraphicAdapterCheck
   {
//       [DllExport("adddays", CallingConvention = CallingConvention.StdCall)]
//       static double AddDays(double dateValue, int days)
//       {
//          return DateTime.FromOADate(dateValue).AddDays(days).ToOADate();
//       }

      [DllExport("GetGPUAdapterName", CallingConvention.StdCall)]
      [return: MarshalAs(UnmanagedType.LPWStr)]
      public static string GetGPUAdapterName()
      {
          ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_VideoController ");
          string graphicsCard = string.Empty;

          foreach (ManagementObject managementObject in searcher.Get())
          {
              foreach (PropertyData property in managementObject.Properties)
              {
                  if (property.Name != "Name")
                  {
                      continue;
                  }
                  graphicsCard = property.Value.ToString();
              }
          }
          return graphicsCard;
      }
   }
}

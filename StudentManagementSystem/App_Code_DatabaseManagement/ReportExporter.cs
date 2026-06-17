using System;
using System.Data;
using System.Text;
using System.Web;

namespace LecturerPortal
{
    public static class ReportExporter
    {
        public static void ExportToCSV(DataTable data, string filenameSummary)
        {
            StringBuilder sb = new StringBuilder();
            // Headers
            for (int i = 0; i < data.Columns.Count; i++)
            {
                sb.Append(data.Columns[i].ColumnName + (i == data.Columns.Count - 1 ? "" : ","));
            }
            sb.AppendLine();
            // Rows
            foreach (DataRow row in data.Rows)
            {
                for (int i = 0; i < data.Columns.Count; i++)
                {
                    string cellText = row[i].ToString().Replace(",", ";"); // Prevent break splitting quirks
                    sb.Append(cellText + (i == data.Columns.Count - 1 ? "" : ","));
                }
                sb.AppendLine();
            }

            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.Buffer = true;
            HttpContext.Current.Response.AddHeader("content-disposition", $"attachment;filename={filenameSummary}.csv");
            HttpContext.Current.Response.Charset = "";
            HttpContext.Current.Response.ContentType = "application/text";
            HttpContext.Current.Response.Output.Write(sb.ToString());
            HttpContext.Current.Response.Flush();
            HttpContext.Current.Response.End();
        }

        public static void ExportToOfficeHTML(DataTable data, string filename, string doctype)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<table border='1' style='font-family:Segoe UI,sans-serif; border-collapse:collapse;'>");
            sb.Append("<tr style='background:#f4f4f6; font-weight:bold;'>");
            foreach (DataColumn col in data.Columns)
            {
                sb.Append($"<th style='padding:8px;'>{col.ColumnName}</th>");
            }
            sb.Append("</tr>");

            foreach (DataRow row in data.Rows)
            {
                sb.Append("<tr>");
                foreach (var cell in row.ItemArray)
                {
                    sb.Append($"<td style='padding:6px;'>{HttpUtility.HtmlEncode(cell.ToString())}</td>");
                }
                sb.Append("</tr>");
            }
            sb.Append("</table>");

            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.Buffer = true;
            HttpContext.Current.Response.AddHeader("content-disposition", $"attachment;filename={filename}");
            HttpContext.Current.Response.Charset = "";

            if (doctype == "doc")
            {
                HttpContext.Current.Response.ContentType = "application/msword";
            }
            else if (doctype == "pdf")
            {
                // Native server-free text-based reporting channel structure fallback mapping
                HttpContext.Current.Response.ContentType = "application/pdf";
            }
            else
            {
                HttpContext.Current.Response.ContentType = "application/vnd.ms-excel";
            }

            HttpContext.Current.Response.Output.Write(sb.ToString());
            HttpContext.Current.Response.Flush();
            HttpContext.Current.Response.End();
        }
    }
}
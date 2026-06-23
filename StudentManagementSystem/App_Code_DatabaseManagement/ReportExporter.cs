using System;
using System.Data;
using System.Text;
using System.Web;

namespace LecturerPortal
{
    public static class ReportExporter
    {
        public static void ExportToCSV(DataTable data, string filenameSummary, string title)
        {
            StringBuilder sb = new StringBuilder();

            // 1. Output ONLY the clear text title at the very top
            if (!string.IsNullOrEmpty(title))
            {
                sb.AppendLine(title.Replace(",", ";"));
                sb.AppendLine(); // Single empty line separation
            }

            // 2. Column Headers from Database
            for (int i = 0; i < data.Columns.Count; i++)
            {
                sb.Append(data.Columns[i].ColumnName + (i == data.Columns.Count - 1 ? "" : ","));
            }
            sb.AppendLine();

            // 3. Pure Rows Data
            foreach (DataRow row in data.Rows)
            {
                for (int i = 0; i < data.Columns.Count; i++)
                {
                    string cellText = row[i].ToString().Replace(",", ";"); // Prevent breaks or splitting quirks
                    sb.Append(cellText + (i == data.Columns.Count - 1 ? "" : ","));
                }
                sb.AppendLine();
            }

            WriteResponse(sb.ToString(), $"{filenameSummary}.csv", "text/csv");
        }

        public static void ExportToOfficeHTML(DataTable data, string filename, string doctype, string title)
        {
            string contentType;
            switch (doctype)
            {
                case "doc":
                    contentType = "application/msword";
                    break;
                case "xls":
                default:
                    contentType = "application/vnd.ms-excel";
                    break;
            }

            StringBuilder sb = new StringBuilder();

            // Explicitly encapsulate within an isolated HTML body block so application layout elements cannot bleed in
            sb.Append("<html><body>");

            // 1. Render ONLY the plain header text
            if (!string.IsNullOrEmpty(title))
            {
                sb.Append($"<h2>{HttpUtility.HtmlEncode(title)}</h2><br/>");
            }

            // 2. Open standard clean data table grid
            sb.Append("<table border='1' style='border-collapse:collapse; font-family:Arial, sans-serif;'>");

            // Header Row
            sb.Append("<tr style='background-color:#f2f2f2;'>");
            foreach (DataColumn col in data.Columns)
            {
                sb.Append($"<th style='padding:6px 12px; text-align:left;'>{HttpUtility.HtmlEncode(col.ColumnName)}</th>");
            }
            sb.Append("</tr>");

            // Data Rows
            foreach (DataRow row in data.Rows)
            {
                sb.Append("<tr>");
                foreach (var cell in row.ItemArray)
                {
                    sb.Append($"<td style='padding:6px 12px;'>{HttpUtility.HtmlEncode(cell.ToString())}</td>");
                }
                sb.Append("</tr>");
            }

            sb.Append("</table>");
            sb.Append("</body></html>");

            WriteResponse(sb.ToString(), filename, contentType);
        }

        private static void WriteResponse(string content, string filename, string contentType)
        {
            var response = HttpContext.Current.Response;

            response.Clear();
            response.Buffer = true;
            response.Charset = "";
            response.ContentType = contentType;
            response.AddHeader("content-disposition", $"attachment;filename=\"{filename}\"");
            response.Output.Write(content);
            response.Flush();

            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
    }
}
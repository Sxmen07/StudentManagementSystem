using System;
using System.Data;
using System.Text;
using System.Web;

namespace StudentManagementSystem.LecturerPortal   // Match your existing namespace
{
    /// <summary>
    /// Static helper class for exporting DataTables to CSV, Excel, and Word formats.
    /// </summary>
    public static class ReportExporter
    {
        /// <summary>
        /// Exports a DataTable to a CSV file and sends it to the client browser.
        /// </summary>
        /// <param name="dt">DataTable containing the data to export.</param>
        /// <param name="fileName">Base file name (without extension).</param>
        /// <exception cref="ArgumentException">Thrown when the DataTable is null or empty.</exception>
        public static void ExportToCSV(DataTable dt, string fileName)
        {
            if (dt == null || dt.Rows.Count == 0)
                throw new ArgumentException("No data to export.", nameof(dt));

            var sb = new StringBuilder();

            // Write column headers
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                sb.Append(EscapeCsvField(dt.Columns[i].ColumnName));
                if (i < dt.Columns.Count - 1)
                    sb.Append(",");
            }
            sb.AppendLine();

            // Write data rows
            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    string value = row[i]?.ToString() ?? string.Empty;
                    sb.Append(EscapeCsvField(value));
                    if (i < dt.Columns.Count - 1)
                        sb.Append(",");
                }
                sb.AppendLine();
            }

            // Send the response
            var response = HttpContext.Current.Response;
            response.Clear();
            response.ContentType = "text/csv";
            response.AddHeader("Content-Disposition", $"attachment; filename={fileName}.csv");
            response.Write(sb.ToString());
            response.End();
        }

        /// <summary>
        /// Exports a DataTable to an HTML table wrapped in an Office document (Excel .xls or Word .doc).
        /// </summary>
        /// <param name="dt">DataTable containing the data to export.</param>
        /// <param name="fileName">Full file name with extension (e.g., "Report.xls").</param>
        /// <param name="format">Format specifier: "xls" or "doc".</param>
        /// <exception cref="ArgumentException">Thrown when the DataTable is null or empty.</exception>
        public static void ExportToOfficeHTML(DataTable dt, string fileName, string format)
        {
            if (dt == null || dt.Rows.Count == 0)
                throw new ArgumentException("No data to export.", nameof(dt));

            var html = new StringBuilder();
            html.Append("<html><head><meta charset='utf-8'></head><body>");
            html.Append("<table border='1' cellpadding='5' cellspacing='0'>");

            // Column headers
            html.Append("<tr>");
            foreach (DataColumn col in dt.Columns)
            {
                html.Append($"<th>{HttpUtility.HtmlEncode(col.ColumnName)}</th>");
            }
            html.Append("</tr>");

            // Data rows
            foreach (DataRow row in dt.Rows)
            {
                html.Append("<tr>");
                foreach (DataColumn col in dt.Columns)
                {
                    string value = row[col]?.ToString() ?? string.Empty;
                    html.Append($"<td>{HttpUtility.HtmlEncode(value)}</td>");
                }
                html.Append("</tr>");
            }

            html.Append("</table></body></html>");

            // Determine MIME type and extension
            string contentType = (format == "doc") ? "application/msword" : "application/vnd.ms-excel";
            string extension = (format == "doc") ? ".doc" : ".xls";

            // Ensure filename has correct extension
            if (!fileName.EndsWith(extension, StringComparison.OrdinalIgnoreCase))
                fileName += extension;

            // Send response
            var response = HttpContext.Current.Response;
            response.Clear();
            response.ContentType = contentType;
            response.AddHeader("Content-Disposition", $"attachment; filename={fileName}");
            response.Write(html.ToString());
            response.End();
        }

        /// <summary>
        /// Escapes a field for CSV output by wrapping in double quotes if it contains commas, quotes, or newlines.
        /// </summary>
        private static string EscapeCsvField(string field)
        {
            if (string.IsNullOrEmpty(field))
                return string.Empty;

            // If the field contains a comma, double-quote, or newline, wrap it in quotes and escape embedded quotes
            bool needsQuoting = field.Contains(",") || field.Contains("\"") || field.Contains("\n") || field.Contains("\r");
            if (needsQuoting)
            {
                field = field.Replace("\"", "\"\""); // Escape double quotes
                return $"\"{field}\"";
            }
            return field;
        }
    }
}
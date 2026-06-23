using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Linq;

namespace StudentManagementSystems.Student
{
    public partial class StudentAcademicResult : Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadFilterOptions();
                LoadAcademicResults();
            }
        }

        private void LoadFilterOptions()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT DISTINCT 
                        s.Semester + ' ' + CAST(co.Year AS VARCHAR) AS SemesterDisplay,
                        co.Year,
                        s.SemesterID
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                    WHERE e.StudentID = @StudentID
                    ORDER BY co.Year DESC, s.SemesterID DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                SqlDataReader dr = cmd.ExecuteReader();
                ddlSemesterFilter.Items.Clear();
                ddlSemesterFilter.Items.Add(new ListItem("All Semesters", "all"));
                while (dr.Read())
                {
                    string semesterDisplay = dr["SemesterDisplay"].ToString();
                    ddlSemesterFilter.Items.Add(new ListItem(semesterDisplay, semesterDisplay));
                }
            }
        }

        private void LoadAcademicResults()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            string filterSemester;
            string sortBy;

            if (IsPostBack)
            {
                filterSemester = ddlSemesterFilter.SelectedValue;
                sortBy = ddlSortBy.SelectedValue;
                ViewState["FilterSemester"] = filterSemester;
                ViewState["SortBy"] = sortBy;
            }
            else
            {
                filterSemester = ViewState["FilterSemester"]?.ToString() ?? "all";
                sortBy = ViewState["SortBy"]?.ToString() ?? "code_asc";
                if (ddlSemesterFilter.Items.FindByValue(filterSemester) != null)
                    ddlSemesterFilter.SelectedValue = filterSemester;
                if (ddlSortBy.Items.FindByValue(sortBy) != null)
                    ddlSortBy.SelectedValue = sortBy;
            }

            Dictionary<string, TempCourse> tempCourses = new Dictionary<string, TempCourse>();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"
                    SELECT 
                        C.CourseCode, 
                        C.CourseName, 
                        C.CreditHours, 
                        CO.Year,
                        Sem.Semester AS SemesterName,
                        A.AssessmentID, 
                        A.AssessmentName, 
                        A.MaxMarks, 
                        A.Weightage,
                        ISNULL(SA.ObtainedMark, 0) AS ObtainedMark
                    FROM Enrolment E
                    INNER JOIN CourseOffer CO ON E.CourseOfferID = CO.CourseOfferID
                    INNER JOIN Course C ON CO.CourseCode = C.CourseCode
                    INNER JOIN Semester Sem ON CO.SemesterID = Sem.SemesterID
                    LEFT JOIN Assessment A ON CO.CourseOfferID = A.CourseOfferID
                    LEFT JOIN StudentAssessment SA ON A.AssessmentID = SA.AssessmentID AND E.StudentID = SA.StudentID
                    WHERE E.StudentID = @StudentID";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@StudentID", studentId);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string courseKey = dr["CourseCode"].ToString() + "_" + dr["Year"].ToString() + "_" + dr["SemesterName"].ToString();
                        if (!tempCourses.ContainsKey(courseKey))
                        {
                            tempCourses[courseKey] = new TempCourse
                            {
                                CourseCode = dr["CourseCode"].ToString(),
                                CourseName = dr["CourseName"].ToString(),
                                CreditHours = Convert.ToInt32(dr["CreditHours"]),
                                Year = Convert.ToInt32(dr["Year"]),
                                SemesterName = dr["SemesterName"].ToString(),
                                Assessments = new List<AssessmentResult>(),
                                TotalWeightage = 0
                            };
                        }

                        var course = tempCourses[courseKey];
                        if (dr["AssessmentID"] != DBNull.Value)
                        {
                            var assessment = new AssessmentResult
                            {
                                AssessmentName = dr["AssessmentName"].ToString(),
                                MaxMarks = Convert.ToDecimal(dr["MaxMarks"]),
                                Weightage = Convert.ToDecimal(dr["Weightage"]),
                                ObtainedMark = Convert.ToDecimal(dr["ObtainedMark"])
                            };
                            course.Assessments.Add(assessment);
                            course.TotalWeightage += assessment.Weightage;
                        }
                    }
                }
            }

            List<CourseAcademicRow> flatResults = new List<CourseAcademicRow>();
            decimal totalWeightGpaPoints = 0;
            int totalCreditsCgpa = 0;

            foreach (var course in tempCourses.Values)
            {
                bool isComplete = course.Assessments.Count > 0 && course.TotalWeightage >= 99.9m;
                string semesterDisplay = course.SemesterName + " " + course.Year;

                if (filterSemester != "all" && filterSemester != semesterDisplay)
                    continue;

                if (!isComplete) continue; // skip incomplete courses

                decimal totalPercentage = 0;
                foreach (var ass in course.Assessments)
                {
                    if (ass.MaxMarks > 0)
                        totalPercentage += (ass.ObtainedMark / ass.MaxMarks) * ass.Weightage;
                }
                totalPercentage = Math.Round(totalPercentage, 2);

                Tuple<string, decimal> gradeMatrix = CalculateGradeAndPoint(totalPercentage);
                string grade = gradeMatrix.Item1;
                decimal gradePoint = gradeMatrix.Item2;

                flatResults.Add(new CourseAcademicRow
                {
                    CourseCode = course.CourseCode,
                    CourseName = course.CourseName,
                    CreditHours = course.CreditHours,
                    Year = course.Year,
                    SemesterDisplay = semesterDisplay,
                    Assessments = course.Assessments,
                    TotalPercentage = totalPercentage,
                    Grade = grade,
                    GradePoint = gradePoint
                });

                totalWeightGpaPoints += gradePoint * course.CreditHours;
                totalCreditsCgpa += course.CreditHours;
            }

            // Apply sorting
            switch (sortBy)
            {
                case "code_asc":
                    flatResults = flatResults.OrderBy(c => c.CourseCode).ToList();
                    break;
                case "code_desc":
                    flatResults = flatResults.OrderByDescending(c => c.CourseCode).ToList();
                    break;
                case "total_desc":
                    flatResults = flatResults.OrderByDescending(c => c.TotalPercentage).ToList();
                    break;
                case "total_asc":
                    flatResults = flatResults.OrderBy(c => c.TotalPercentage).ToList();
                    break;
                case "gpa_desc":
                    flatResults = flatResults.OrderByDescending(c => c.GradePoint).ToList();
                    break;
                case "gpa_asc":
                    flatResults = flatResults.OrderBy(c => c.GradePoint).ToList();
                    break;
            }

            gvAcademicResults.DataSource = flatResults;
            gvAcademicResults.DataBind();

            decimal cgpa = totalCreditsCgpa > 0 ? Math.Round(totalWeightGpaPoints / totalCreditsCgpa, 2) : 0;
            lblCGPA.Text = cgpa.ToString("0.00");
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            LoadAcademicResults();
        }

        protected void btnResetFilter_Click(object sender, EventArgs e)
        {
            ViewState["FilterSemester"] = "all";
            ViewState["SortBy"] = "code_asc";
            ddlSemesterFilter.SelectedValue = "all";
            ddlSortBy.SelectedValue = "code_asc";
            LoadAcademicResults();
        }

        private Tuple<string, decimal> CalculateGradeAndPoint(decimal percentage)
        {
            if (percentage >= 80) return Tuple.Create("A", 4.00m);
            if (percentage >= 75) return Tuple.Create("A-", 3.75m);
            if (percentage >= 70) return Tuple.Create("B+", 3.50m);
            if (percentage >= 65) return Tuple.Create("B", 3.00m);
            if (percentage >= 60) return Tuple.Create("B-", 2.75m);
            if (percentage >= 55) return Tuple.Create("C+", 2.50m);
            if (percentage >= 50) return Tuple.Create("C", 2.00m);
            if (percentage >= 45) return Tuple.Create("D", 1.00m);
            return Tuple.Create("F", 0.00m);
        }

        protected void gvAcademicResults_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                CourseAcademicRow row = (CourseAcademicRow)e.Row.DataItem;

                // Bind the nested repeaters
                Repeater rptNames = (Repeater)e.Row.FindControl("rptAssessmentNames");
                if (rptNames != null)
                {
                    rptNames.DataSource = row.Assessments;
                    rptNames.DataBind();
                }

                Repeater rptScores = (Repeater)e.Row.FindControl("rptScores");
                if (rptScores != null)
                {
                    rptScores.DataSource = row.Assessments;
                    rptScores.DataBind();
                }

                Repeater rptWeighted = (Repeater)e.Row.FindControl("rptWeightedScores");
                if (rptWeighted != null)
                {
                    rptWeighted.DataSource = row.Assessments;
                    rptWeighted.DataBind();
                }

                // Color grade cell (Grade column index is 8)
                TableCell gradeCell = e.Row.Cells[8];
                if (row.Grade != null)
                {
                    string colorClass = GetGradeColor(row.Grade);
                    gradeCell.CssClass = (gradeCell.CssClass + " " + colorClass).Trim();
                }
            }
        }

        protected string GetGradeColor(string grade)
        {
            if (grade == "N/A") return "text-gray-500";
            if (grade.StartsWith("A")) return "text-green-600";
            if (grade.StartsWith("B")) return "text-blue-600";
            if (grade.StartsWith("C")) return "text-yellow-600";
            if (grade.StartsWith("D")) return "text-orange-600";
            return "text-red-600";
        }

        private int GetStudentIdFromSession()
        {
            if (Session["StudentID"] != null)
                return Convert.ToInt32(Session["StudentID"]);

            string email = Session["UserEmail"]?.ToString();
            if (string.IsNullOrEmpty(email)) return 0;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        int id = Convert.ToInt32(result);
                        Session["StudentID"] = id;
                        return id;
                    }
                }
            }
            return 0;
        }

        // ----- Helper Classes -----
        public class AssessmentResult
        {
            public string AssessmentName { get; set; }
            public decimal MaxMarks { get; set; }
            public decimal Weightage { get; set; }
            public decimal ObtainedMark { get; set; }
        }

        public class TempCourse
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int CreditHours { get; set; }
            public int Year { get; set; }
            public string SemesterName { get; set; }
            public List<AssessmentResult> Assessments { get; set; }
            public decimal TotalWeightage { get; set; }
        }

        public class CourseAcademicRow
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int CreditHours { get; set; }
            public int Year { get; set; }
            public string SemesterDisplay { get; set; }
            public List<AssessmentResult> Assessments { get; set; }
            public decimal TotalPercentage { get; set; }
            public string Grade { get; set; }
            public decimal GradePoint { get; set; }
        }
    }
}
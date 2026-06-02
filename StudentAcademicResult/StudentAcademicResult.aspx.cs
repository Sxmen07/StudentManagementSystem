using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace StudentManagementSystem.Student
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
                LoadAcademicResults();
            }
        }

        private void LoadAcademicResults()
        {
            string email = Session["UserEmail"].ToString();
            Dictionary<string, TempSemester> tempSemesters = new Dictionary<string, TempSemester>();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"
                    SELECT 
                        C.CourseCode, C.CourseName, C.CreditHours, CO.Year,
                        S.SemesterID, Sem.Semester AS SemesterName,
                        A.AssessmentID, A.AssessmentName, A.MaxMarks, A.Weightage,
                        ISNULL(SA.ObtainedMark, 0) AS ObtainedMark
                    FROM Enrolment E
                    INNER JOIN CourseOffer CO ON E.CourseOfferID = CO.CourseOfferID
                    INNER JOIN Course C ON CO.CourseCode = C.CourseCode
                    INNER JOIN Student S ON E.StudentID = S.StudentID
                    INNER JOIN Semester Sem ON CO.SemesterID = Sem.SemesterID
                    LEFT JOIN Assessment A ON CO.CourseOfferID = A.CourseOfferID
                    LEFT JOIN StudentAssessment SA ON A.AssessmentID = SA.AssessmentID AND S.StudentID = SA.StudentID
                    WHERE S.StudentEmail = @Email";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", email);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string semKey = dr["SemesterID"].ToString() + "_" + dr["Year"].ToString();
                        if (!tempSemesters.ContainsKey(semKey))
                        {
                            tempSemesters[semKey] = new TempSemester
                            {
                                SemesterID = Convert.ToInt32(dr["SemesterID"]),
                                SemesterName = dr["SemesterName"].ToString(),
                                Year = Convert.ToInt32(dr["Year"])
                            };
                        }

                        var tempSem = tempSemesters[semKey];
                        string courseCode = dr["CourseCode"].ToString();

                        if (!tempSem.Courses.ContainsKey(courseCode))
                        {
                            tempSem.Courses[courseCode] = new CourseResult
                            {
                                CourseCode = courseCode,
                                CourseName = dr["CourseName"].ToString(),
                                CreditHours = Convert.ToInt32(dr["CreditHours"]),
                                Assessments = new List<AssessmentResult>()
                            };
                        }

                        var courseRes = tempSem.Courses[courseCode];

                        if (dr["AssessmentID"] != DBNull.Value)
                        {
                            courseRes.Assessments.Add(new AssessmentResult
                            {
                                AssessmentName = dr["AssessmentName"].ToString(),
                                MaxMarks = Convert.ToDecimal(dr["MaxMarks"]),
                                Weightage = Convert.ToDecimal(dr["Weightage"]),
                                ObtainedMark = Convert.ToDecimal(dr["ObtainedMark"])
                            });
                        }
                    }
                }
            }

            List<SemesterResult> finalResults = new List<SemesterResult>();
            decimal totalWeightGpaPoints = 0;
            int totalCreditsCgpa = 0;

            foreach (var kvp in tempSemesters)
            {
                var tempSem = kvp.Value;
                var semResult = new SemesterResult
                {
                    SemesterName = tempSem.SemesterName,
                    Year = tempSem.Year,
                    Courses = new List<CourseResult>()
                };

                decimal semTotalGradePoints = 0;
                int semTotalCredits = 0;

                foreach (var cKvp in tempSem.Courses)
                {
                    var course = cKvp.Value;
                    decimal totalPercentage = 0;

                    foreach (var ass in course.Assessments)
                    {
                        if (ass.MaxMarks > 0)
                        {
                            totalPercentage += (ass.ObtainedMark / ass.MaxMarks) * ass.Weightage;
                        }
                    }
                    course.TotalPercentage = Math.Round(totalPercentage, 2);

                    // Grade mapping rules matrix
                    Tuple<string, decimal> gradeMatrix = CalculateGradeAndPoint(course.TotalPercentage);
                    course.Grade = gradeMatrix.Item1;
                    course.GradePoint = gradeMatrix.Item2;

                    semTotalGradePoints += course.GradePoint * course.CreditHours;
                    semTotalCredits += course.CreditHours;

                    semResult.Courses.Add(course);
                }

                semResult.GPA = semTotalCredits > 0 ? Math.Round(semTotalGradePoints / semTotalCredits, 2) : 0;

                totalWeightGpaPoints += semTotalGradePoints;
                totalCreditsCgpa += semTotalCredits;

                finalResults.Add(semResult);
            }

            if (finalResults.Count > 0)
            {
                rptSemesters.DataSource = finalResults;
                rptSemesters.DataBind();
                lblNoResults.Visible = false;
            }
            else
            {
                lblNoResults.Visible = true;
            }

            decimal cgpa = totalCreditsCgpa > 0 ? Math.Round(totalWeightGpaPoints / totalCreditsCgpa, 2) : 0;
            lblCGPA.Text = cgpa.ToString("0.00");
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

        protected void rptSemesters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // Get the current data item bound to this row
                SemesterResult semester = (SemesterResult)e.Item.DataItem;

                // Find the inner repeater control
                Repeater rptCourses = (Repeater)e.Item.FindControl("rptCourses");

                // 2. Safe check to ensure the control was successfully found
                if (rptCourses != null && semester != null)
                {
                    rptCourses.DataSource = semester.Courses;
                    rptCourses.DataBind();
                }
            }
        }

        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                CourseResult course = (CourseResult)e.Item.DataItem;
                Repeater rptAssessments = (Repeater)e.Item.FindControl("rptAssessments");
                if (rptAssessments != null)
                {
                    rptAssessments.DataSource = course.Assessments;
                    rptAssessments.DataBind();
                }
            }
        }

        protected string GetGradeColor(string grade)
        {
            if (grade.StartsWith("A")) return "text-green-600";
            if (grade.StartsWith("B")) return "text-blue-600";
            if (grade.StartsWith("C")) return "text-yellow-600";
            if (grade.StartsWith("D")) return "text-orange-600";
            return "text-red-600";
        }

        // Helper classes
        public class AssessmentResult
        {
            public string AssessmentName { get; set; }
            public decimal MaxMarks { get; set; }
            public decimal Weightage { get; set; }
            public decimal ObtainedMark { get; set; }
        }

        public class CourseResult
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int CreditHours { get; set; }
            public List<AssessmentResult> Assessments { get; set; }
            public decimal TotalPercentage { get; set; }
            public string Grade { get; set; }
            public decimal GradePoint { get; set; }
        }

        public class SemesterResult
        {
            public string SemesterName { get; set; }
            public int Year { get; set; }
            public List<CourseResult> Courses { get; set; }
            public decimal GPA { get; set; }
        }

        public class TempSemester
        {
            public int SemesterID { get; set; }
            public string SemesterName { get; set; }
            public int Year { get; set; }
            public Dictionary<string, CourseResult> Courses { get; set; } = new Dictionary<string, CourseResult>();
        }
    }
}
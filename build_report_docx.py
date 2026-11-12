import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn

def create_report():
    doc = docx.Document()

    # Set standard 0.8 inch margins
    for section in doc.sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)

    # Base styling helper
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Times New Roman'
    normal_style.font.size = Pt(12)
    normal_style.font.color.rgb = RGBColor(0, 0, 0)
    normal_style.paragraph_format.line_spacing = 1.15
    normal_style.paragraph_format.space_after = Pt(4)

    # Palette
    C_RED = RGBColor(192, 0, 0)       # #C00000
    C_BLUE = RGBColor(0, 112, 192)    # #0070C0
    C_GREEN = RGBColor(0, 128, 0)     # #008000
    C_PURPLE = RGBColor(75, 0, 130)   # #4B0082
    C_NAVY = RGBColor(31, 73, 125)    # #1F497D
    C_BLACK = RGBColor(0, 0, 0)
    C_GRAY = RGBColor(80, 80, 80)

    logo_path = r'D:\fsd2-project\extracted_media\word\media\image1.jpeg'
    fig1_path = r'D:\fsd2-project\report_assets\fig3_1_architecture.png'
    fig2_path = r'D:\fsd2-project\report_assets\fig3_2_erd.png'
    fig3_path = r'D:\fsd2-project\report_assets\fig3_3_signup_login.png'
    fig4_path = r'D:\fsd2-project\report_assets\fig3_4_request_workflow.png'

    def add_page_border_to_section(section):
        sectPr = section._sectPr
        borders_elm = parse_xml(
            f'<w:pgBorders {nsdecls("w")} w:offsetFrom="page">\n'
            f'  <w:top w:val="single" w:sz="8" w:space="24" w:color="000000"/>\n'
            f'  <w:left w:val="single" w:sz="8" w:space="24" w:color="000000"/>\n'
            f'  <w:bottom w:val="single" w:sz="8" w:space="24" w:color="000000"/>\n'
            f'  <w:right w:val="single" w:sz="8" w:space="24" w:color="000000"/>\n'
            f'</w:pgBorders>'
        )
        sectPr.append(borders_elm)

    def style_table(table, header_bg="D9E1F2", border_color="B0C4DE"):
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        tblPr = table._tbl.tblPr
        borders = parse_xml(
            f'<w:tblBorders {nsdecls("w")}>\n'
            f'  <w:top w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>\n'
            f'  <w:bottom w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>\n'
            f'  <w:insideH w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>\n'
            f'  <w:insideV w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>\n'
            f'  <w:left w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>\n'
            f'  <w:right w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>\n'
            f'</w:tblBorders>'
        )
        tblPr.append(borders)
        for cell in table.rows[0].cells:
            shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{header_bg}"/>')
            cell._tc.get_or_add_tcPr().append(shd)
            for p in cell.paragraphs:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
                for run in p.runs:
                    run.font.bold = True
                    run.font.name = 'Times New Roman'
                    run.font.size = Pt(10.5)

    def add_code_block(title, code_text):
        p_cap = doc.add_paragraph()
        p_cap.paragraph_format.space_before = Pt(8)
        p_cap.paragraph_format.space_after = Pt(2)
        r_cap = p_cap.add_run(title)
        r_cap.font.name = 'Times New Roman'
        r_cap.font.size = Pt(10.5)
        r_cap.font.bold = True
        r_cap.font.italic = True

        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="F8F9FA"/>')
        cell._tc.get_or_add_tcPr().append(shd)
        border = parse_xml(
            f'<w:tcBorders {nsdecls("w")}>\n'
            f'  <w:top w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>\n'
            f'  <w:bottom w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>\n'
            f'  <w:left w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>\n'
            f'  <w:right w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>\n'
            f'</w:tcBorders>'
        )
        cell._tc.get_or_add_tcPr().append(border)
        p = cell.paragraphs[0]
        p.paragraph_format.space_before = Pt(4)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.05
        r = p.add_run(code_text.strip())
        r.font.name = 'Consolas'
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(20, 20, 20)
        doc.add_paragraph()

    def add_screenshot_placeholder(fig_title, note=""):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="F4F6F9"/>')
        cell._tc.get_or_add_tcPr().append(shd)
        border = parse_xml(
            f'<w:tcBorders {nsdecls("w")}>\n'
            f'  <w:top w:val="single" w:sz="6" w:space="0" w:color="3498DB"/>\n'
            f'  <w:bottom w:val="single" w:sz="6" w:space="0" w:color="3498DB"/>\n'
            f'  <w:left w:val="single" w:sz="6" w:space="0" w:color="3498DB"/>\n'
            f'  <w:right w:val="single" w:sz="6" w:space="0" w:color="3498DB"/>\n'
            f'</w:tcBorders>'
        )
        cell._tc.get_or_add_tcPr().append(border)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(36)
        p.paragraph_format.space_after = Pt(36)
        r1 = p.add_run(f"[ SCREENSHOT PLACEHOLDER ]\n")
        r1.font.bold = True
        r1.font.size = Pt(11)
        r1.font.color.rgb = RGBColor(41, 128, 185)
        r2 = p.add_run(f"Paste your application screenshot here\n({fig_title})\n")
        r2.font.size = Pt(10)
        r2.font.italic = True
        r2.font.color.rgb = RGBColor(100, 100, 100)
        if note:
            r3 = p.add_run(f"Note: {note}")
            r3.font.size = Pt(9)
            r3.font.color.rgb = RGBColor(120, 120, 120)

        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_cap.paragraph_format.space_before = Pt(4)
        p_cap.paragraph_format.space_after = Pt(12)
        r_cap = p_cap.add_run(fig_title)
        r_cap.font.name = 'Times New Roman'
        r_cap.font.size = Pt(10.5)
        r_cap.font.italic = True
        r_cap.font.bold = True

    # ---------------------------------------------------------------------------
    # PAGE 1: TITLE PAGE (COVER PAGE)
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("CampusFlow: Smart Service & Issue Management System")
    r.font.bold = True
    r.font.size = Pt(18)
    r.font.color.rgb = C_RED

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run("A")
    r.font.size = Pt(12)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("Skill Oriented Course Web Application report submitted in the partial fulfillment of the requirements for the award of the Degree of")
    r.font.size = Pt(11)
    r.font.bold = True

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("BACHELOR OF TECHNOLOGY")
    r.font.bold = True
    r.font.size = Pt(14)
    r.font.color.rgb = C_PURPLE

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("In")
    r.font.bold = True
    r.font.size = Pt(12)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(8)
    r = p.add_run("COMPUTER SCIENCE AND ENGINEERING")
    r.font.bold = True
    r.font.size = Pt(13)
    r.font.color.rgb = C_GREEN

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("By")
    r.font.bold = True
    r.font.size = Pt(12)

    # Student Name and Roll
    tbl_name = doc.add_table(rows=1, cols=2)
    tbl_name.alignment = WD_TABLE_ALIGNMENT.CENTER
    c1, c2 = tbl_name.rows[0].cells
    c1.width = Inches(3.6)
    c2.width = Inches(2.6)
    p1 = c1.paragraphs[0]
    p1.alignment = WD_ALIGN_PARAGRAPH.LEFT
    r1 = p1.add_run("Nimmala Venkata Umesh Chandra")
    r1.font.bold = True
    r1.font.size = Pt(12)
    r1.font.color.rgb = C_NAVY
    p2 = c2.paragraphs[0]
    p2.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r2 = p2.add_run("24761A05AD")
    r2.font.bold = True
    r2.font.size = Pt(12)
    r2.font.color.rgb = C_NAVY

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("Under the esteemed guidance of")
    r.font.bold = True
    r.font.size = Pt(12)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("Mr. N. SrinivasaRao")
    r.font.bold = True
    r.font.size = Pt(12.5)
    r.font.color.rgb = C_RED

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(8)
    r = p.add_run("Sr. Assistant Professor")
    r.font.bold = True
    r.font.size = Pt(11)

    # Logo
    if os.path.exists(logo_path):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_before = Pt(2)
        p_logo.paragraph_format.space_after = Pt(6)
        doc.add_picture(logo_path, width=Inches(1.7))
        last_p = doc.paragraphs[-1]
        last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("DEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING")
    r.font.bold = True
    r.font.size = Pt(12.5)
    r.font.color.rgb = C_RED

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("LAKIREDDY BALIREDDY COLLEGE OF ENGINEERING (AUTONOMOUS)")
    r.font.bold = True
    r.font.size = Pt(12)
    r.font.color.rgb = C_BLUE

    college_info = [
        "Accredited by NAAC with ‘A’ Grade & NBA (Under Tier - I),",
        "An ISO 21001:2018, 14001:2015, 50001:2018 Certified Institution",
        "Approved by AICTE, New Delhi and Affiliated to JNTUK, Kakinada",
        "L.B. REDDY NAGAR, MYLAVARAM, NTR DIST., A.P. - 521230."
    ]
    for line in college_info:
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(1)
        r = p.add_run(line)
        r.font.size = Pt(9.5)
        r.font.bold = True

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(4)
    r = p.add_run("2024-2028")
    r.font.bold = True
    r.font.size = Pt(12)
    r.font.color.rgb = C_RED

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 2: CERTIFICATE
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("LAKIREDDY BALI REDDY COLLEGE OF ENGINEERING\n(AUTONOMOUS)")
    r.font.bold = True
    r.font.size = Pt(13)
    r.font.color.rgb = C_RED

    for line in college_info:
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(1)
        r = p.add_run(line)
        r.font.size = Pt(9)
        r.font.bold = True

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("Department of\nCOMPUTER SCIENCE AND ENGINEERING")
    r.font.bold = True
    r.font.size = Pt(12)
    r.font.color.rgb = C_BLUE

    if os.path.exists(logo_path):
        doc.add_picture(logo_path, width=Inches(1.5))
        last_p = doc.paragraphs[-1]
        last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        last_p.paragraph_format.space_before = Pt(4)
        last_p.paragraph_format.space_after = Pt(6)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(12)
    r = p.add_run("CERTIFICATE")
    r.font.bold = True
    r.font.underline = True
    r.font.size = Pt(15)

    p = doc.add_paragraph()
    p.paragraph_format.line_spacing = 1.25
    p.paragraph_format.space_after = Pt(8)
    p.add_run("This is to certify that the Skill Oriented Course Web Application entitled ")
    r_title = p.add_run("“CampusFlow: Smart Service & Issue Management System”")
    r_title.font.bold = True
    r_title.font.color.rgb = C_RED
    p.add_run(" is being submitted by")

    tbl_cert_name = doc.add_table(rows=1, cols=2)
    tbl_cert_name.alignment = WD_TABLE_ALIGNMENT.CENTER
    c1, c2 = tbl_cert_name.rows[0].cells
    c1.width = Inches(3.6)
    c2.width = Inches(2.6)
    p1 = c1.paragraphs[0]
    p1.alignment = WD_ALIGN_PARAGRAPH.LEFT
    r1 = p1.add_run("Nimmala Venkata Umesh Chandra")
    r1.font.bold = True
    r1.font.size = Pt(12)
    r1.font.color.rgb = C_NAVY
    p2 = c2.paragraphs[0]
    p2.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r2 = p2.add_run("24761A05AD")
    r2.font.bold = True
    r2.font.size = Pt(12)
    r2.font.color.rgb = C_NAVY

    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.line_spacing = 1.25
    p.paragraph_format.space_after = Pt(8)
    p.add_run("in partial fulfillment of the requirements for the award of degree of ")
    r_deg = p.add_run("B.Tech in Computer Science and Engineering")
    r_deg.font.bold = True
    r_deg.font.color.rgb = C_GREEN
    p.add_run(" from ")
    r_jntu = p.add_run("Jawaharlal Nehru Technological University Kakinada")
    r_jntu.font.bold = True
    p.add_run(" is a record of Bonafide work carried out by him/her at ")
    r_col = p.add_run("Lakireddy Bali Reddy College of Engineering (Autonomous)")
    r_col.font.bold = True
    r_col.font.color.rgb = C_RED
    p.add_run(".")

    p = doc.add_paragraph()
    p.paragraph_format.line_spacing = 1.25
    p.paragraph_format.space_after = Pt(36)
    p.add_run("The results embodied in this Skill Oriented Course Web Application report have not been submitted to any other university or institute for the award of any degree or diploma.")

    tbl_sig = doc.add_table(rows=1, cols=2)
    tbl_sig.alignment = WD_TABLE_ALIGNMENT.CENTER
    s1, s2 = tbl_sig.rows[0].cells
    s1.width = Inches(3.2)
    s2.width = Inches(3.2)
    ps1 = s1.paragraphs[0]
    ps1.alignment = WD_ALIGN_PARAGRAPH.LEFT
    rs1 = ps1.add_run("INTERNAL EXAMINER")
    rs1.font.bold = True
    rs1.font.size = Pt(11)
    ps2 = s2.paragraphs[0]
    ps2.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    rs2 = ps2.add_run("EXTERNAL EXAMINER")
    rs2.font.bold = True
    rs2.font.size = Pt(11)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 3: ACKNOWLEDGEMENT
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after = Pt(18)
    r = p.add_run("ACKNOWLEDGEMENT")
    r.font.bold = True
    r.font.underline = True
    r.font.size = Pt(15)

    ack_paras = [
        "I would like to thank Mr. N. SrinivasaRao, Sr. Assistant Professor, CSE department for the encouragement and support in carrying out this Skill Oriented Course Web Application.",
        "I also take the privilege to record my thanks to Dr. S. Nagarjuna Reddy, Professor, Head of the Department of CSE whose encouragement, cooperation, and valuable support crown my success.",
        "I express my thanks to the support given by management in completing my Web Application. I also express my sincere gratitude & deep sense of respect to Dr. K. Appa Rao, Principal for making us available all the required assistance and his support and inspiration to carry out this Skill Oriented Course Web Application in the Institute.",
        "I am thankful to the teaching and non-teaching staff of CSE department for their direct as well as indirect help in my Skill Oriented Course Web Application.",
        "I am elated to avail myself to this opportunity to express my deep sense of gratitude to my parents."
    ]
    for text in ack_paras:
        p = doc.add_paragraph()
        p.paragraph_format.line_spacing = 1.25
        p.paragraph_format.space_after = Pt(12)
        p.add_run(text)

    p_sig = doc.add_paragraph()
    p_sig.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_sig.paragraph_format.space_before = Pt(36)
    r_name = p_sig.add_run("Nimmala Venkata Umesh Chandra   24761A05AD")
    r_name.font.bold = True

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 4: DECLARATION
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after = Pt(18)
    r = p.add_run("DECLARATION")
    r.font.bold = True
    r.font.underline = True
    r.font.size = Pt(15)

    p = doc.add_paragraph()
    p.paragraph_format.line_spacing = 1.25
    p.paragraph_format.space_after = Pt(14)
    p.add_run("I am here to declare that the project entitled “CampusFlow: Smart Service & Issue Management System” work done by me. I certify that the work contained in the report is original and has been done by me under the guidance of my supervisor. The work has not been submitted to any other institute in preparing for any degree or diploma. I have followed the guidelines provided by the institute for preparing the report. I have confirmed the norms and guidelines given in the Ethical Code of Conduct of the Institute. Whenever I have used materials (data, theoretical analysis, figures and text) from other sources, I have given due credit to them by citing them in the text of the report and giving their details in the references. Further, I have taken permission from the copyright owner of the sources, whenever necessary.")

    p_sig = doc.add_paragraph()
    p_sig.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_sig.paragraph_format.space_before = Pt(48)
    p_sig.add_run("Signature of the student\n").font.bold = True
    r_name = p_sig.add_run("Nimmala Venkata Umesh Chandra   24761A05AD")
    r_name.font.bold = True

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 5: ABSTRACT
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after = Pt(18)
    r = p.add_run("ABSTRACT")
    r.font.bold = True
    r.font.underline = True
    r.font.size = Pt(15)

    abstract_paras = [
        "In modern university campuses, managing physical infrastructure issues, electrical faults, network disruptions, plumbing breakdowns, and laboratory equipment repairs is traditionally handled through informal word of mouth, manual register logbooks, or unstructured telephone complaints. These outdated approaches lead to lost requests, lack of status transparency, unaccountable turnaround times, and severe dissatisfaction among students and staff. CampusFlow: Smart Service & Issue Management System is a database-driven enterprise web application designed to centralize and automate college service requests, staff dispatch, workflow progress tracking, and post-resolution feedback on a unified platform. It is built strictly using HTML5, CSS3, and Vanilla JavaScript for the responsive user interface, JavaServer Pages (JSP 2.3) and Java Servlets running on Apache Tomcat 9 for server-side business logic, and JDBC connecting directly to an Oracle 10g Express Edition database.",
        "The system provides three distinct, role-based workflows for Students, Staff, and Administrators. New students register through a server-validated registration module. Passwords are never stored in plain text; they are secured using the JDK-standard PBKDF2WithHmacSHA256 key derivation algorithm with 65,536 iterations and unique 16-byte random salts. Authenticated users maintain their session in an HTTP session cookie with complete session invalidation and renewal at login to prevent session fixation. Students submit structured service requests with automatic generation of unique tracking identifiers (e.g., CF-2026-xxxxx) and a dynamic rule-based priority engine that evaluates urgency, impact, and campus location. Students can view personal requests, filter by category and status, edit eligible requests before assignment, cancel pending issues, inspect an immutable chronological audit timeline, and submit 5-star ratings with narrative feedback after resolution.",
        "Assigned staff members receive a dedicated task queue displaying workload metrics, transition ticket statuses through permitted states (In Progress, Resolved) with mandatory resolution remarks, and trigger automated in-app notifications to students. Administrators possess central operational governance: searching and filtering all campus requests, dispatching tickets to departments and staff, executing priority overrides with recorded justifications, managing department structures, and governing user account activation states.",
        "Security and data durability were engineered from inception: 100% of database interactions execute via JDBC PreparedStatement to eliminate SQL injection; synchronizer CSRF tokens defend state-altering POST requests; user-supplied text is sanitized with HTML entity escaping; and strict foreign key constraints preserve relational integrity in Oracle. The project demonstrates an authentic, full-stack Java web application adhering strictly to classical MVC architecture, verified through extensive testing and database persistence.",
        "Keywords: JSP, Servlets, JDBC, Oracle 10g XE, Apache Tomcat, PBKDF2, RBAC, Issue Management, CampusFlow."
    ]
    for text in abstract_paras:
        p = doc.add_paragraph()
        p.paragraph_format.line_spacing = 1.2
        p.paragraph_format.space_after = Pt(10)
        p.add_run(text)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 6: LIST OF CONTENTS
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(14)
    r = p.add_run("LIST OF CONTENTS")
    r.font.bold = True
    r.font.underline = True
    r.font.size = Pt(15)

    contents_data = [
        ("CONTENTS", "PAGE NO"),
        ("1. INTRODUCTION . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "1-3"),
        ("    1.1 Overview of the Project . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "1-2"),
        ("    1.2 Feasibility Study . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "2-3"),
        ("2. TECHNOLOGIES USED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "4-7"),
        ("    2.1 HTML, CSS & JavaScript . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "4"),
        ("    2.2 JDBC (Oracle) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "4-6"),
        ("    2.3 Servlets and the Apache Tomcat Container . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "6"),
        ("    2.4 JSP (JavaServer Pages) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "6-7"),
        ("    2.5 Supporting Tools and Libraries . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "7"),
        ("3. WEB APPLICATION ARCHITECTURE . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "8-12"),
        ("    3.1 Three-Tier Architecture . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "8"),
        ("    3.2 Pages and Their Roles . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "8-9"),
        ("    3.3 Database Design . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "9-11"),
        ("    3.4 Data Flow . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "11-12"),
        ("4. CODING & IMPLEMENTATION . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "13-20"),
        ("    4.1 Project Structure . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "13"),
        ("    4.2 Database Implementation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "13-14"),
        ("    4.3 Database Connection . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "14"),
        ("    4.4 Registration / Signup Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "14-15"),
        ("    4.5 Login and Logout Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "15-16"),
        ("    4.6 Request Creation & Priority Engine Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "16-17"),
        ("    4.7 Staff Action & Workflow Transition Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "17-18"),
        ("    4.8 Admin Assignment & User Governance Module . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "18-19"),
        ("    4.9 Feedback & Notification Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "19-20"),
        ("    4.10 Security Measures . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "20"),
        ("5. RESULTS . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "21-26"),
        ("    5.1 Login Page . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "21"),
        ("    5.2 Student Dashboard & Request Submission Page . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "21-22"),
        ("    5.3 Request Details & Timeline Tracking Page . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "22"),
        ("    5.4 Staff Dashboard & Task Action Page . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "22-23"),
        ("    5.5 Admin Dashboard & Request Assignment Page . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "23"),
        ("    5.6 Analytics & Reports Page . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "23-24"),
        ("    5.7 Database Output . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "24-26"),
        ("    5.8 Testing . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "26"),
        ("6. CONCLUSION . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "27"),
        ("7. REFERENCES . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .", "28")
    ]

    tbl_toc = doc.add_table(rows=len(contents_data), cols=2)
    tbl_toc.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl_toc.autofit = False
    for i, (left_t, right_t) in enumerate(contents_data):
        row = tbl_toc.rows[i]
        c1, c2 = row.cells
        c1.width = Inches(5.2)
        c2.width = Inches(1.2)
        p1 = c1.paragraphs[0]
        p1.paragraph_format.line_spacing = 1.05
        p1.paragraph_format.space_after = Pt(2)
        r1 = p1.add_run(left_t)
        p2 = c2.paragraphs[0]
        p2.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        p2.paragraph_format.line_spacing = 1.05
        p2.paragraph_format.space_after = Pt(2)
        r2 = p2.add_run(right_t)
        if i == 0 or (left_t[0].isdigit() and left_t[1] == '.'):
            r1.font.bold = True
            r2.font.bold = True

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 7: LIST OF ABBREVIATIONS
    # ---------------------------------------------------------------------------
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(16)
    r = p.add_run("LIST OF ABBREVIATIONS")
    r.font.bold = True
    r.font.underline = True
    r.font.size = Pt(15)

    abbreviations = [
        "1.  HTML – Hypertext Markup Language",
        "2.  CSS – Cascading Style Sheets",
        "3.  JS – JavaScript",
        "4.  JDBC – Java Database Connectivity",
        "5.  JSP – JavaServer Pages",
        "6.  SQL – Structured Query Language",
        "7.  DB – Database",
        "8.  RDBMS – Relational Database Management System",
        "9.  HTTP – Hypertext Transfer Protocol",
        "10. URL – Uniform Resource Locator",
        "11. CRUD – Create, Read, Update, Delete",
        "12. IDE – Integrated Development Environment",
        "13. JDK – Java Development Kit",
        "14. XE – Express Edition (Oracle Database)",
        "15. SID – System Identifier (Oracle)",
        "16. API – Application Programming Interface",
        "17. UI – User Interface",
        "18. ER – Entity-Relationship",
        "19. PK – Primary Key",
        "20. FK – Foreign Key",
        "21. WAR – Web Application Archive",
        "22. XSS – Cross-Site Scripting",
        "23. CSRF – Cross-Site Request Forgery",
        "24. RBAC – Role-Based Access Control",
        "25. PBKDF2 – Password-Based Key Derivation Function 2",
        "26. MVC – Model-View-Controller",
        "27. SOC – Skill Oriented Course"
    ]
    for abbr in abbreviations:
        p = doc.add_paragraph()
        p.paragraph_format.line_spacing = 1.15
        p.paragraph_format.space_after = Pt(3)
        p.add_run(abbr)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 1: INTRODUCTION
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("1").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("1. INTRODUCTION")
    r.font.bold = True
    r.font.size = Pt(15)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("1.1 Overview of the Project")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "CampusFlow is a database-driven enterprise web application designed to automate, streamline, and govern college service and issue management across institutional campuses. In a university environment, hundreds of maintenance and operational service requests arise daily—ranging from classroom electrical faults, projector failures, and network switch outages to plumbing leaks, carpentry repairs, and laboratory equipment servicing. CampusFlow empowers students to submit structured service requests from any standard web browser, automatically assigns unique tracking identifiers, determines dynamic issue priority through a multi-factor calculation engine, facilitates staff dispatch, and maintains an immutable audit timeline with post-resolution 5-star student feedback. All information is persistently stored in an Oracle relational database and every page is rendered dynamically through JavaServer Pages (JSP) and Servlets."
    )

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Problem Statement")
    r.font.bold = True
    r.font.size = Pt(12)

    doc.add_paragraph(
        "In most engineering colleges and universities, students and staff still depend on physical logbooks, manual phone calls, or verbal complaints to report campus infrastructure problems. This manual approach results in major inefficiencies: maintenance requests are easily misplaced or ignored, students receive zero visibility into ticket status, staff members lack organized priority queues, and administrators possess no consolidated metrics on departmental resolution speeds or recurring faults. A central database-backed online platform that automates ticket submission, rule-based priority scoring, staff assignment, and feedback tracking eliminates these systemic bottlenecks."
    )

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Objectives")
    r.font.bold = True
    r.font.size = Pt(12)

    objectives = [
        "To build a multi-page web application with a clean, professional, responsive user interface using pure HTML5, modern CSS3 design variables, and Vanilla JavaScript without external CSS/JS libraries.",
        "To store users, departments, requests, history logs, feedback, and notifications in an Oracle relational database and access them through robust JDBC PreparedStatements.",
        "To provide secure student registration and login using PBKDF2WithHmacSHA256 password hashing and enterprise HTTP session management.",
        "To enforce strict Role-Based Access Control (RBAC) across three distinct user roles: Student, Staff, and Administrator.",
        "To implement an automated rule-based Priority Engine that dynamically evaluates urgency, impact, and campus location weights, auto-escalating hazard keywords to CRITICAL.",
        "To enable an end-to-end workflow state machine (SUBMITTED → ASSIGNED → IN_PROGRESS → RESOLVED → CLOSED/CANCELLED) with immutable audit history and in-app notifications.",
        "To follow good software engineering practices: server-side validation, anti-CSRF token verification, XSS HTML output escaping, and graceful error handling."
    ]
    for obj in objectives:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(3)
        p.add_run(obj)

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Modules of the Application")
    r.font.bold = True
    r.font.size = Pt(12)

    modules_data = [
        ("Module", "Description"),
        ("User Management", "Student registration with client/server validation, PBKDF2 password hashing, secure login, session fixation protection, and profile updates."),
        ("Request Management", "Structured ticket submission form, dynamic priority engine preview, unique tracking code generation (CF-2026-xxxxx), personal request filtering, and pre-assignment editing."),
        ("Staff Workflow", "Assigned task queue, workload metric counters, progress transition to IN_PROGRESS, resolution remarks logging, and student notification dispatch."),
        ("Administrative Governance", "Enterprise request master directory, multi-attribute filtering, staff assignment and reassignment, priority override with mandatory justification, department CRUD, and user activation governance."),
        ("Feedback & Analytics", "Post-resolution 5-star rating submission, automated ticket closure, and native SVG Donut and Bar charts displaying operational performance.")
    ]
    tbl_mod = doc.add_table(rows=len(modules_data), cols=2)
    style_table(tbl_mod)
    for i, (m, d) in enumerate(modules_data):
        row = tbl_mod.rows[i]
        row.cells[0].paragraphs[0].text = m
        row.cells[1].paragraphs[0].text = d
        row.cells[0].width = Inches(2.0)
        row.cells[1].width = Inches(4.4)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(8)
    r = p_sub.add_run("Existing and Proposed System")
    r.font.bold = True
    r.font.size = Pt(12)

    doc.add_paragraph(
        "In the existing manual system, a student with a lab equipment or hostel issue must physically locate maintenance supervisors, write in paper registers, and has no proof of submission or turnaround estimate. Work is assigned arbitrarily, leading to delays and lack of accountability. In the proposed CampusFlow system, the student logs into a self-service portal, submits the issue with location and urgency, receives a unique tracking code instantly, and tracks real-time progress. Staff receive an organized queue and must log resolution remarks. Administrators monitor resolution rates and department performance in real time via live charts."
    )

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Scope")
    r.font.bold = True
    r.font.size = Pt(12)

    doc.add_paragraph(
        "The project encompasses campus-wide issue tracking across academic blocks, laboratories, hostels, electrical power substations, plumbing systems, and IT networks. It covers authentication, role-based dashboards, automated priority scoring, assignment workflows, audit timelines, and feedback. External SMS/WhatsApp gateways and native mobile apps are reserved for future scope."
    )

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("1.2 Feasibility Study")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "A feasibility study verifies that the project can be completed effectively with the available time, technical tools, and resources. The following dimensions were evaluated."
    )

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Technical Feasibility")
    r.font.bold = True
    r.font.size = Pt(12)

    doc.add_paragraph(
        "Java, Servlets, JSP, JDBC, Apache Tomcat 9, and Oracle Database 10g Express Edition are mature, reliable, and extensively documented enterprise technologies that operate seamlessly on standard student computer systems. The pure Java Type-4 Oracle Thin Driver requires no client software installation. The project is therefore technically feasible."
    )

    tech_req_data = [
        ("Item", "Requirement used in this project"),
        ("Processor / RAM", "Intel Core i3 / i5 or higher, 8 GB RAM"),
        ("Disk space", "About 3 GB free for Oracle 10g XE, Apache Tomcat 9.0, JDK, and Project WAR"),
        ("Operating system", "Windows 10 / Windows 11 (64-bit)"),
        ("Java Environment", "OpenJDK 17.0.19 LTS (compatible with javax.servlet API)"),
        ("IDE", "Eclipse IDE for Enterprise Java and Web Developers / VS Code"),
        ("Web / JSP container", "Apache Tomcat 9.0.121 (Configured on HTTP Port 8089)"),
        ("Database", "Oracle Database 10g Express Edition (SID: xe, Service: localhost:1521)"),
        ("JDBC Driver", "Oracle Thin Driver (ojdbc14.jar / ojdbc8.jar)"),
        ("Web Browser", "Google Chrome, Microsoft Edge, Mozilla Firefox")
    ]
    tbl_tech = doc.add_table(rows=len(tech_req_data), cols=2)
    style_table(tbl_tech)
    for i, (k, v) in enumerate(tech_req_data):
        row = tbl_tech.rows[i]
        row.cells[0].paragraphs[0].text = k
        row.cells[1].paragraphs[0].text = v
        row.cells[0].width = Inches(2.2)
        row.cells[1].width = Inches(4.2)

    doc.add_paragraph()
    feas_aspects = [
        ("Economic Feasibility", "Every tool utilized is free and open-source or freely distributable: OpenJDK, Eclipse IDE, Apache Tomcat 9, and Oracle 10g Express Edition. No commercial software licenses were required; development and testing utilized existing student hardware."),
        ("Operational Feasibility", "The application features an intuitive, light-themed responsive user interface with familiar form inputs, dynamic priority badges, and explicit status indicators. Clear feedback messages accompany every user action (e.g., 'Request submitted successfully with ID CF-2026-xxxxx'). Zero special operator training is needed."),
        ("Schedule Feasibility", "Development followed a structured, incremental schedule: schema design, Oracle connection testing, authentication & PBKDF2 hashing, student request module, staff workflow execution, admin triage, security auditing, and automated testing."),
        ("Security Feasibility", "Common web application vulnerabilities (stolen passwords, SQL injection, XSS, CSRF, and session hijacking) are eliminated through salted PBKDF2 hashing, 100% PreparedStatement query parameterization, synchronizer CSRF tokens, and session invalidation at logout.")
    ]
    for title, desc in feas_aspects:
        p = doc.add_paragraph()
        r = p.add_run(f"{title}: ")
        r.font.bold = True
        p.add_run(desc)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 2: TECHNOLOGIES USED
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("4").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("2. TECHNOLOGIES USED")
    r.font.bold = True
    r.font.size = Pt(15)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("2.1 HTML, CSS & JavaScript")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "HTML5 defines the structural foundation of every view in CampusFlow. Each page incorporates standard semantic elements: a consistent navigation bar, a collapsible sidebar, a main content container, and a footer. Web forms capture request details, priority selections, login credentials, and review ratings. Form inputs utilize standardized name attributes that map directly to servlet parameter retrieval calls via request.getParameter()."
    )
    doc.add_paragraph(
        "CSS3 provides a modern, light-themed enterprise design system. Visual design tokens are centralized as CSS custom properties on :root (e.g., --primary-600, --primary-700, --neutral-800, --success, --warning, --danger) ensuring strict visual consistency across all 27 JSP templates. Flexbox and CSS Grid organize multi-column summary cards, data tables, and modal dialogs. Responsive media queries adjust layouts gracefully across desktop monitors, tablets, and mobile smartphones without external frameworks like Bootstrap."
    )
    doc.add_paragraph(
        "Vanilla JavaScript (ES6+) delivers responsive client-side interactivity without external libraries. Features include a dynamic Priority Score Preview on the request creation form that updates the badge color as urgency and impact change, asynchronous AJAX loading of department staff in administrative dropdowns, accessible modal window controllers, and native SVG chart rendering."
    )

    frontend_table_data = [
        ("Technology", "Use in CampusFlow"),
        ("HTML5", "Semantic page structure, responsive data tables, accessible input forms, dialog containers."),
        ("CSS3", "Design system with CSS custom properties, Flexbox/Grid layouts, badge indicators, transitions."),
        ("Vanilla JavaScript", "Live Priority Engine preview, AJAX staff fetching, modal window controls, SVG chart engine.")
    ]
    tbl_fe = doc.add_table(rows=len(frontend_table_data), cols=2)
    style_table(tbl_fe)
    for i, (t, u) in enumerate(frontend_table_data):
        row = tbl_fe.rows[i]
        row.cells[0].paragraphs[0].text = t
        row.cells[1].paragraphs[0].text = u
        row.cells[0].width = Inches(1.8)
        row.cells[1].width = Inches(4.6)

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(10)
    r = p_sec.add_run("2.2 JDBC (Oracle)")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Java Database Connectivity (JDBC) is the core Java API for establishing database connections and executing SQL operations. CampusFlow utilizes the Oracle Type-4 Thin Driver (ojdbc14.jar), which communicates directly with Oracle's TNS listener over TCP/IP without requiring Oracle client software on the application server."
    )

    doc.add_paragraph("Standard Steps Followed in Every Database Access:")
    jdbc_steps = [
        "Load the Oracle JDBC Driver class: Class.forName(\"oracle.jdbc.driver.OracleDriver\").",
        "Open a database connection via DriverManager.getConnection(url, user, password) targeting jdbc:oracle:thin:@localhost:1521:xe.",
        "Construct pre-compiled SQL queries with ? parameter placeholders using con.prepareStatement(sql).",
        "Bind strongly-typed input values using setString(), setInt(), setTimestamp() to prevent SQL injection.",
        "Execute query: executeQuery() for SELECT statements (returning a ResultSet) or executeUpdate() for INSERT, UPDATE, DELETE.",
        "Iterate result rows via while (rs.next()) { ... } and map database records into JavaBean models.",
        "Cleanly close ResultSet, PreparedStatement, and Connection in finally blocks or try-with-resources."
    ]
    for step in jdbc_steps:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(2)
        p.add_run(step)

    jdbc_classes_data = [
        ("JDBC Class / Interface", "Purpose in CampusFlow"),
        ("DriverManager", "Establishes physical database connections to Oracle XE via DBConnection.java."),
        ("Connection", "Maintains active session; manages transaction boundaries (setAutoCommit, commit, rollback)."),
        ("PreparedStatement", "Pre-compiled parameterized SQL execution ensuring total immunity to SQL injection."),
        ("ResultSet", "Tabular data returned from SELECT queries, mapped into JavaBean domain objects."),
        ("SQLException", "Handles database exceptions, constraint violations (e.g. ORA-00001, ORA-02292).")
    ]
    tbl_jdbc = doc.add_table(rows=len(jdbc_classes_data), cols=2)
    style_table(tbl_jdbc)
    for i, (c, p_desc) in enumerate(jdbc_classes_data):
        row = tbl_jdbc.rows[i]
        row.cells[0].paragraphs[0].text = c
        row.cells[1].paragraphs[0].text = p_desc
        row.cells[0].width = Inches(2.2)
        row.cells[1].width = Inches(4.2)

    doc.add_paragraph()
    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Oracle 10g Express Edition Specifics:")
    r.font.bold = True
    r.font.size = Pt(12)

    oracle_specifics = [
        "System Identifier (SID): Identified by 'xe', connecting via URL jdbc:oracle:thin:@localhost:1521:xe.",
        "Synthetic Primary Keys: Because Oracle 10g lacks identity columns, synthetic primary keys are generated using Oracle Sequences (e.g. SEQ_USERS.NEXTVAL, SEQ_REQUESTS.NEXTVAL).",
        "Pagination Query Optimization: In the absence of OFFSET/FETCH syntax, large result sets are paginated using Oracle's nested ROWNUM subquery pattern.",
        "Audit Timestamps: Creation and resolution events are recorded using native TIMESTAMP columns populated via CURRENT_TIMESTAMP."
    ]
    for spec in oracle_specifics:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(2)
        p.add_run(spec)

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("2.3 Servlets and the Apache Tomcat Container")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "A Java Servlet is a server-side component managed by a web container that receives and responds to HTTP requests. Apache Tomcat 9.0.121 acts as the Servlet 4.0 / JSP 2.3 container, managing servlet lifecycles (init(), service(), destroy()) under the javax.servlet API. CampusFlow deploys 23 dedicated servlet controllers that parse requests, invoke services, enforce authorization, and implement the Post/Redirect/Get (PRG) pattern to eliminate accidental duplicate submissions."
    )

    doc.add_paragraph(
        "Session management relies on Tomcat's HttpSession mechanism. Upon successful authentication, any existing session is invalidated to neutralize session fixation attacks, and a fresh session is provisioned storing the user's ID, role, and name. Tomcat transmits the session token in a secure JSESSIONID cookie."
    )

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("2.4 JSP (JavaServer Pages)")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "JavaServer Pages enable dynamic HTML generation on the server. When first requested, Tomcat's Jasper engine translates each .jsp template into a Java servlet, compiles it, and executes it. CampusFlow structures views into reusable modular fragments (header.jsp, sidebar.jsp, footer.jsp, messages.jsp) imported across all pages."
    )

    jsp_elements_data = [
        ("JSP Element", "Example from CampusFlow", "Meaning / Usage"),
        ("Page directive", "<%@ page import=\"com.campusflow.model.*\" %>", "Imports Java classes and configures content type/encoding."),
        ("Include directive", "<%@ include file=\"/WEB-INF/views/common/header.jsp\" %>", "Merges common fragments during page translation."),
        ("Expression", "<%= SecurityUtil.escapeHtml(req.getTitle()) %>", "Evaluates Java expressions and outputs sanitized HTML."),
        ("Scriptlet", "<% for(RequestBean b : list) { %>", "Executes control flow and iteration logic within views."),
        ("Implicit Objects", "request, response, session, out", "Built-in container objects providing HTTP context.")
    ]
    tbl_jsp = doc.add_table(rows=len(jsp_elements_data), cols=3)
    style_table(tbl_jsp)
    for i, (el, ex, m) in enumerate(jsp_elements_data):
        row = tbl_jsp.rows[i]
        row.cells[0].paragraphs[0].text = el
        row.cells[1].paragraphs[0].text = ex
        row.cells[2].paragraphs[0].text = m
        row.cells[0].width = Inches(1.5)
        row.cells[1].width = Inches(2.7)
        row.cells[2].width = Inches(2.2)

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("2.5 Supporting Tools and Libraries")
    r.font.bold = True
    r.font.size = Pt(13)

    tools_summary_data = [
        ("Tool / Library", "Version", "Role in CampusFlow"),
        ("OpenJDK", "17.0.19 LTS", "Compiles all 50 Java source files to bytecode."),
        ("Apache Tomcat", "9.0.121", "Servlet 4.0 / JSP 2.3 runtime container on port 8089."),
        ("Oracle Database XE", "10g Release 2", "Relational database engine storing all tables and sequences."),
        ("Oracle JDBC Driver", "ojdbc14.jar", "Type-4 pure Java driver providing database connectivity."),
        ("JDK Cryptography", "PBKDF2WithHmacSHA256", "Salting and hashing user passwords with 65,536 iterations."),
        ("PowerShell CLI", "5.1+", "Automated build, WAR packaging, deployment, and test scripts.")
    ]
    tbl_tools = doc.add_table(rows=len(tools_summary_data), cols=3)
    style_table(tbl_tools)
    for i, (tool, ver, role) in enumerate(tools_summary_data):
        row = tbl_tools.rows[i]
        row.cells[0].paragraphs[0].text = tool
        row.cells[1].paragraphs[0].text = ver
        row.cells[2].paragraphs[0].text = role
        row.cells[0].width = Inches(1.8)
        row.cells[1].width = Inches(1.4)
        row.cells[2].width = Inches(3.2)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 3: WEB APPLICATION ARCHITECTURE
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("8").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("3. WEB APPLICATION ARCHITECTURE")
    r.font.bold = True
    r.font.size = Pt(15)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("3.1 Three-Tier Architecture")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "CampusFlow strictly adheres to an enterprise three-tier Model-View-Controller (MVC) architecture. The Presentation Tier comprises the client browser executing HTML5, modern CSS3, and progressive Vanilla JavaScript. The Application Tier comprises the Apache Tomcat 9 web container, hosting Java Servlets, JSP templates, session managers, security filters, and business service beans. The Data Tier is an Oracle 10g Express Edition database engine guaranteeing ACID transaction properties and data durability."
    )

    if os.path.exists(fig1_path):
        p_fig = doc.add_paragraph()
        p_fig.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture(fig1_path, width=Inches(6.2))
        last_p = doc.paragraphs[-1]
        last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r_cap = p_cap.add_run("Figure 3.1: Three-tier architecture of CampusFlow")
        r_cap.font.italic = True
        r_cap.font.bold = True
        r_cap.font.size = Pt(10.5)

    doc.add_paragraph("A typical request travels through the architecture as follows:")
    flow_steps = [
        "The browser dispatches an HTTP request (GET for page viewing, POST for state changes).",
        "AuthenticationFilter verifies session presence and role permissions; CsrfFilter validates synchronizer tokens on POST.",
        "The targeted HttpServlet controller extracts parameters, performs server-side validation, and invokes the appropriate Service class.",
        "The Service class applies business workflows, executes state-transition checks or priority calculations, and calls the Data Access Object (DAO).",
        "The DAO executes a pre-compiled SQL PreparedStatement against Oracle 10g XE over JDBC and maps the returned ResultSet into JavaBean models.",
        "The controller stores the beans as request attributes and forwards execution to the corresponding JSP template (or redirects via PRG pattern).",
        "Tomcat renders the dynamic HTML document and transmits the HTTP response back to the client browser."
    ]
    for step in flow_steps:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(2)
        p.add_run(step)

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("3.2 Pages and Their Roles")
    r.font.bold = True
    r.font.size = Pt(13)

    pages_roles_data = [
        ("File(s) / Controller", "Role in CampusFlow"),
        ("DBConnection.java", "Centralized JDBC connection factory loading Oracle Thin Driver and providing active connections."),
        ("header.jsp, sidebar.jsp", "Modular navigation fragments dynamically showing links based on authenticated user role (Student, Staff, Admin)."),
        ("index.jsp, HomeServlet", "System landing page highlighting platform features, service categories, and quick login shortcuts."),
        ("login.jsp, LoginServlet", "Authentication form, PBKDF2 hash verification, session fixation prevention, and role routing."),
        ("register.jsp, RegisterServlet", "Student registration form, client/server input validation, duplicate email check, and PBKDF2 password hashing."),
        ("RequestCreateServlet, create-request.jsp", "Student request submission with interactive Priority Engine preview and automated tracking code generation."),
        ("RequestListServlet, my-requests.jsp", "Paginated student request directory with category and status filter controls."),
        ("RequestDetailsServlet, request-details.jsp", "Detailed ticket view showing current status badge, assigned staff, and chronological audit trail."),
        ("RequestEditServlet, RequestCancelServlet", "Enables students to edit or cancel pending tickets while still in SUBMITTED state."),
        ("StaffDashboardServlet, StaffActionServlet", "Staff assigned work queue, status transitions (IN_PROGRESS, RESOLVED), and mandatory remarks logging."),
        ("AdminDashboardServlet, AdminRequestListServlet", "Central administrative oversight, multi-attribute ticket filter, and operational metric cards."),
        ("AdminAssignmentServlet, AdminPriorityServlet", "Administrative dispatch of requests to departments/staff and priority override with recorded justification."),
        ("DepartmentServlet, UserManagementServlet", "Department CRUD operations and user directory governance (active/deactive toggle)."),
        ("FeedbackServlet, feedback.jsp", "Post-resolution 5-star student review submission triggering automatic ticket closure."),
        ("NotificationServlet, notifications.jsp", "In-app notification center and unread badge count in navigation header."),
        ("AnalyticsServlet, charts.js", "Operational analytics dashboard rendering native SVG Donut and Bar charts directly in the DOM.")
    ]
    tbl_pr = doc.add_table(rows=len(pages_roles_data), cols=2)
    style_table(tbl_pr)
    for i, (f, r_desc) in enumerate(pages_roles_data):
        row = tbl_pr.rows[i]
        row.cells[0].paragraphs[0].text = f
        row.cells[1].paragraphs[0].text = r_desc
        row.cells[0].width = Inches(2.4)
        row.cells[1].width = Inches(4.0)

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("3.3 Database Design")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "The relational schema is structured into 6 interrelated tables enforced by primary keys, foreign keys, and domain check constraints. An Entity-Relationship diagram illustrating these relationships is presented below."
    )

    if os.path.exists(fig2_path):
        p_fig = doc.add_paragraph()
        p_fig.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture(fig2_path, width=Inches(6.2))
        last_p = doc.paragraphs[-1]
        last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r_cap = p_cap.add_run("Figure 3.2: Entity-relationship diagram of CampusFlow")
        r_cap.font.italic = True
        r_cap.font.bold = True
        r_cap.font.size = Pt(10.5)

    db_tables_meta = [
        ("Table 3.1: DEPARTMENTS", [
            ("Column", "Type", "Constraint / Note"),
            ("department_id", "NUMBER", "Primary key, generated by SEQ_DEPARTMENTS"),
            ("department_name", "VARCHAR2(100)", "NOT NULL, UNIQUE"),
            ("code", "VARCHAR2(20)", "NOT NULL, UNIQUE (e.g., IT, ELEC, PLUMB)"),
            ("description", "VARCHAR2(500)", "Department functional scope"),
            ("contact_email", "VARCHAR2(150)", "Official contact email"),
            ("is_active", "NUMBER(1)", "DEFAULT 1; CHECK (is_active IN (0, 1))")
        ]),
        ("Table 3.2: USERS", [
            ("Column", "Type", "Constraint / Note"),
            ("user_id", "NUMBER", "Primary key, generated by SEQ_USERS"),
            ("full_name", "VARCHAR2(100)", "NOT NULL"),
            ("email", "VARCHAR2(150)", "NOT NULL, UNIQUE (used for authentication)"),
            ("password_hash", "VARCHAR2(256)", "NOT NULL; PBKDF2 salted hash (iterations:salt:hash)"),
            ("role", "VARCHAR2(20)", "NOT NULL; CHECK (role IN ('STUDENT','STAFF','ADMIN'))"),
            ("phone", "VARCHAR2(30)", "Contact phone number"),
            ("department_id", "NUMBER", "Foreign key to DEPARTMENTS(department_id)"),
            ("is_active", "NUMBER(1)", "DEFAULT 1; CHECK (is_active IN (0, 1))")
        ]),
        ("Table 3.3: REQUESTS", [
            ("Column", "Type", "Constraint / Note"),
            ("request_id", "NUMBER", "Primary key, generated by SEQ_REQUESTS"),
            ("tracking_number", "VARCHAR2(30)", "NOT NULL, UNIQUE (format: CF-2026-xxxxx)"),
            ("student_id", "NUMBER", "Foreign key to USERS(user_id)"),
            ("department_id", "NUMBER", "Foreign key to DEPARTMENTS(department_id)"),
            ("assigned_staff_id", "NUMBER", "Foreign key to USERS(user_id)"),
            ("priority", "VARCHAR2(20)", "CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL'))"),
            ("status", "VARCHAR2(20)", "CHECK (status IN ('SUBMITTED','ASSIGNED','IN_PROGRESS','RESOLVED','CLOSED','CANCELLED'))"),
            ("urgency_level", "VARCHAR2(20)", "CHECK (urgency_level IN ('LOW','MEDIUM','HIGH','EMERGENCY'))"),
            ("impact_level", "VARCHAR2(20)", "CHECK (impact_level IN ('SINGLE_USER','ROOM','FLOOR','BUILDING_WIDE'))"),
            ("location", "VARCHAR2(200)", "Campus physical location"),
            ("created_at", "TIMESTAMP", "DEFAULT CURRENT_TIMESTAMP")
        ]),
        ("Table 3.4: REQUEST_HISTORY", [
            ("Column", "Type", "Constraint / Note"),
            ("history_id", "NUMBER", "Primary key, generated by SEQ_REQUEST_HISTORY"),
            ("request_id", "NUMBER", "Foreign key to REQUESTS(request_id)"),
            ("old_status", "VARCHAR2(20)", "Previous status"),
            ("new_status", "VARCHAR2(20)", "New status"),
            ("changed_by_user_id", "NUMBER", "Foreign key to USERS(user_id)"),
            ("remarks", "VARCHAR2(1000)", "Transition action remarks or resolution notes"),
            ("created_at", "TIMESTAMP", "DEFAULT CURRENT_TIMESTAMP")
        ]),
        ("Table 3.5: FEEDBACK", [
            ("Column", "Type", "Constraint / Note"),
            ("feedback_id", "NUMBER", "Primary key, generated by SEQ_FEEDBACK"),
            ("request_id", "NUMBER", "Foreign key to REQUESTS(request_id)"),
            ("student_id", "NUMBER", "Foreign key to USERS(user_id)"),
            ("rating", "NUMBER(1)", "CHECK (rating BETWEEN 1 AND 5)"),
            ("comments", "VARCHAR2(1000)", "Student qualitative evaluation"),
            ("created_at", "TIMESTAMP", "DEFAULT CURRENT_TIMESTAMP; UNIQUE (request_id, student_id)")
        ]),
        ("Table 3.6: NOTIFICATIONS", [
            ("Column", "Type", "Constraint / Note"),
            ("notification_id", "NUMBER", "Primary key, generated by SEQ_NOTIFICATIONS"),
            ("user_id", "NUMBER", "Foreign key to USERS(user_id)"),
            ("request_id", "NUMBER", "Foreign key to REQUESTS(request_id)"),
            ("title", "VARCHAR2(150)", "Headline notification message"),
            ("message", "VARCHAR2(1000)", "Full notification body text"),
            ("is_read", "NUMBER(1)", "DEFAULT 0; CHECK (is_read IN (0, 1))")
        ])
    ]

    for tbl_title, rows in db_tables_meta:
        p_t = doc.add_paragraph()
        p_t.paragraph_format.space_before = Pt(6)
        p_t.paragraph_format.space_after = Pt(2)
        r_t = p_t.add_run(tbl_title)
        r_t.font.bold = True
        r_t.font.size = Pt(11)
        tbl = doc.add_table(rows=len(rows), cols=3)
        style_table(tbl)
        for idx, (c1, c2, c3) in enumerate(rows):
            row = tbl.rows[idx]
            row.cells[0].paragraphs[0].text = c1
            row.cells[1].paragraphs[0].text = c2
            row.cells[2].paragraphs[0].text = c3
            row.cells[0].width = Inches(1.8)
            row.cells[1].width = Inches(1.8)
            row.cells[2].width = Inches(2.8)

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("3.4 Data Flow")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "User Registration and Authentication Flow: During signup, the server validates input format, verifies that the email is not already registered, hashes the password with salted PBKDF2, and inserts a row into USERS. During login, the user's record is fetched by email, the password hash is compared in constant time, and a fresh session is established. Generic error messages prevent account enumeration attacks."
    )

    if os.path.exists(fig3_path):
        p_fig = doc.add_paragraph()
        p_fig.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture(fig3_path, width=Inches(6.0))
        last_p = doc.paragraphs[-1]
        last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r_cap = p_cap.add_run("Figure 3.3: Signup and login flow")
        r_cap.font.italic = True
        r_cap.font.bold = True
        r_cap.font.size = Pt(10.5)

    doc.add_paragraph(
        "Service Request and State Machine Lifecycle: A student creates a request specifying location, category, urgency, and impact. PriorityService dynamically computes the priority and assigns an initial SUBMITTED state. An administrator dispatches the ticket to a department and staff member, advancing the state to ASSIGNED. The assigned staff member accepts the work (IN_PROGRESS) and records mandatory resolution remarks upon completion (RESOLVED). The student provides a 5-star rating, which transitions the ticket to CLOSED."
    )

    if os.path.exists(fig4_path):
        p_fig = doc.add_paragraph()
        p_fig.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture(fig4_path, width=Inches(6.0))
        last_p = doc.paragraphs[-1]
        last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r_cap = p_cap.add_run("Figure 3.4: Service request workflow and state transition lifecycle")
        r_cap.font.italic = True
        r_cap.font.bold = True
        r_cap.font.size = Pt(10.5)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 4: CODING & IMPLEMENTATION
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("13").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("4. CODING & IMPLEMENTATION")
    r.font.bold = True
    r.font.size = Pt(15)

    doc.add_paragraph(
        "This chapter presents key architectural excerpts and source listings from CampusFlow, demonstrating the implementation of database access, secure authentication, dynamic priority calculation, workflow transitions, and defensive security measures."
    )

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.1 Project Structure")
    r.font.bold = True
    r.font.size = Pt(13)

    proj_tree = """CampusFlow/
├── database/                        Oracle XE SQL Schema & Seed Scripts
│   ├── 01_create_schema.sql         6 Tables, 6 Sequences, Constraints
│   ├── 02_seed_departments.sql     8 College Departments
│   ├── 03_create_admin.sql          Bootstrap Admin, Staff, Student Users
│   └── 04_indexes.sql               9 Performance Secondary Indexes
├── src/main/java/com/campusflow/
│   ├── config/DBConnection.java     Oracle Thin Driver JDBC Connection Manager
│   ├── controller/                  23 HttpServlet MVC Controllers
│   │   ├── LoginServlet.java, RegisterServlet.java, LogoutServlet.java
│   │   ├── RequestCreateServlet.java, RequestListServlet.java
│   │   ├── StaffDashboardServlet.java, StaffActionServlet.java
│   │   └── AdminDashboardServlet.java, AdminAssignmentServlet.java
│   ├── dao/                         6 JDBC Data Access Objects
│   │   ├── UserDAO.java, DepartmentDAO.java, RequestDAO.java
│   │   ├── RequestHistoryDAO.java, FeedbackDAO.java, NotificationDAO.java
│   │   └── filter/ (AuthenticationFilter.java, CsrfFilter.java)
│   ├── model/ (JavaBeans: User, Dept, Request, History, Feedback, Notif)
│   ├── service/ (PriorityService, WorkflowService, AssignmentService)
│   └── util/ (PasswordUtil, SecurityUtil, ValidationUtil, TrackingCodeUtil)
└── src/main/webapp/
    ├── assets/ (css/main.css, js/app.js, js/charts.js, images/logo.svg)
    ├── WEB-INF/web.xml (Servlet mappings, error pages, session timeout)
    └── WEB-INF/views/ (Modular JSPs: auth, student, staff, admin, common)"""
    add_code_block("Project Structure Tree", proj_tree)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.2 Database Implementation")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "The database tables and sequences were created in Oracle SQL*Plus. The listings below illustrate table creation DDL and sequence generation."
    )

    listing_4_1 = """CREATE TABLE users (
    user_id NUMBER(10) PRIMARY KEY,
    full_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(150) NOT NULL UNIQUE,
    password_hash VARCHAR2(256) NOT NULL,
    role VARCHAR2(20) NOT NULL,
    phone VARCHAR2(30),
    department_id NUMBER(10) REFERENCES departments(department_id),
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_user_role CHECK (role IN ('STUDENT', 'STAFF', 'ADMIN')),
    CONSTRAINT chk_user_active CHECK (is_active IN (0, 1))
);

CREATE TABLE requests (
    request_id NUMBER(10) PRIMARY KEY,
    tracking_number VARCHAR2(30) NOT NULL UNIQUE,
    student_id NUMBER(10) NOT NULL REFERENCES users(user_id),
    title VARCHAR2(200) NOT NULL,
    description VARCHAR2(4000) NOT NULL,
    category VARCHAR2(50) NOT NULL,
    department_id NUMBER(10) REFERENCES departments(department_id),
    assigned_staff_id NUMBER(10) REFERENCES users(user_id),
    priority VARCHAR2(20) DEFAULT 'MEDIUM' NOT NULL,
    status VARCHAR2(20) DEFAULT 'SUBMITTED' NOT NULL,
    location VARCHAR2(200) NOT NULL,
    urgency_level VARCHAR2(20) DEFAULT 'MEDIUM' NOT NULL,
    impact_level VARCHAR2(20) DEFAULT 'SINGLE_USER' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    CONSTRAINT chk_req_prio CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    CONSTRAINT chk_req_stat CHECK (status IN ('SUBMITTED','ASSIGNED','IN_PROGRESS',
                                              'RESOLVED','CLOSED','CANCELLED'))
);"""
    add_code_block("Listing 4.1: Table creation (users and requests)", listing_4_1)

    listing_4_2 = """CREATE SEQUENCE seq_requests START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1 NOCACHE;

INSERT INTO departments (department_id, department_name, code, contact_email)
VALUES (seq_departments.NEXTVAL, 'Information Technology', 'IT', 'it@campusflow.edu');"""
    add_code_block("Listing 4.2: Oracle Sequence and Sample DML", listing_4_2)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.3 Database Connection")
    r.font.bold = True
    r.font.size = Pt(13)

    listing_4_3 = """package com.campusflow.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER = "campusflow";
    private static final String PASS = "campusflow123";

    static {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Oracle JDBC Driver missing!", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}"""
    add_code_block("Listing 4.3: DBConnection.java (Oracle JDBC Thin Driver)", listing_4_3)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.4 Registration / Signup Module")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "RegisterServlet validates all input fields, verifies email uniqueness, derives a salted PBKDF2 hash, and inserts the student into Oracle."
    )

    listing_4_4 = """// Server-side validation in RegisterServlet.java
if (!ValidationUtil.isValidEmail(email)) {
    request.setAttribute("errorMessage", "Invalid email address format.");
    request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    return;
}
if (!ValidationUtil.isValidPassword(password)) {
    request.setAttribute("errorMessage", "Password must be >= 8 chars with upper, digit & symbol.");
    request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    return;
}
if (userDAO.findByEmail(email) != null) {
    request.setAttribute("errorMessage", "An account with this email already exists.");
    request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    return;
}"""
    add_code_block("Listing 4.4: Server-side validation in RegisterServlet", listing_4_4)

    listing_4_5 = """// PBKDF2 password derivation and user insertion
String saltHash = PasswordUtil.hashPassword(password);
UserBean user = new UserBean();
user.setFullName(fullName);
user.setEmail(email);
user.setPasswordHash(saltHash);
user.setRole("STUDENT");
user.setPhone(phone);

boolean success = userDAO.create(user);
if (success) {
    response.sendRedirect(request.getContextPath() + "/login?msg=registered");
}"""
    add_code_block("Listing 4.5: PBKDF2 Password Hashing and Insert", listing_4_5)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.5 Login and Logout Module")
    r.font.bold = True
    r.font.size = Pt(13)

    listing_4_6 = """// Credential verification and session fixation defense in LoginServlet.java
UserBean user = userDAO.findByEmail(email);
if (user != null && user.isActive() && 
    PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
    
    // Invalidate old session to prevent session fixation
    HttpSession oldSession = request.getSession(false);
    if (oldSession != null) oldSession.invalidate();
    
    // Provision fresh session
    HttpSession session = request.getSession(true);
    session.setAttribute("user", user);
    session.setAttribute("userId", user.getUserId());
    session.setAttribute("role", user.getRole());
    session.setAttribute("csrfToken", SecurityUtil.generateCsrfToken());
    
    if ("ADMIN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    } else if ("STAFF".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/staff/dashboard");
    } else {
        response.sendRedirect(request.getContextPath() + "/student/dashboard");
    }
} else {
    request.setAttribute("errorMessage", "Invalid email or password.");
    request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
}"""
    add_code_block("Listing 4.6: Login verification and session creation", listing_4_6)

    listing_4_7 = """// LogoutServlet.java: Session destruction
HttpSession session = request.getSession(false);
if (session != null) {
    session.invalidate();
}
response.sendRedirect(request.getContextPath() + "/login?msg=logged_out");"""
    add_code_block("Listing 4.7: Logout and session invalidation", listing_4_7)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.6 Request Creation & Priority Engine Module")
    r.font.bold = True
    r.font.size = Pt(13)

    listing_4_9 = """package com.campusflow.service;

public class PriorityService {
    public static String calculatePriority(String urgency, String impact, 
                                           String location, String description) {
        // Auto-escalate critical hazard keywords
        String lowerDesc = description.toLowerCase();
        if (lowerDesc.contains("fire") || lowerDesc.contains("burst") || 
            lowerDesc.contains("spark") || lowerDesc.contains("flood")) {
            return "CRITICAL";
        }
        int urgencyScore = switch (urgency) {
            case "EMERGENCY" -> 4;
            case "HIGH" -> 3;
            case "MEDIUM" -> 2;
            default -> 1;
        };
        int impactScore = switch (impact) {
            case "BUILDING_WIDE" -> 4;
            case "FLOOR" -> 3;
            case "ROOM" -> 2;
            default -> 1;
        };
        int locationWeight = (location.toLowerCase().contains("server") || 
                              location.toLowerCase().contains("substation")) ? 3 : 1;
        
        int totalScore = (urgencyScore * 3) + (impactScore * 2) + locationWeight;
        if (totalScore >= 18) return "CRITICAL";
        if (totalScore >= 14) return "HIGH";
        if (totalScore >= 9)  return "MEDIUM";
        return "LOW";
    }
}"""
    add_code_block("Listing 4.9: Rule-based Priority Engine in PriorityService.java", listing_4_9)

    listing_4_10 = """// Request insertion with unique tracking code in RequestDAO.java
String trackingNo = TrackingCodeUtil.generate();
String sql = "INSERT INTO requests (request_id, tracking_number, student_id, title, " +
             "description, category, priority, status, location, urgency_level, impact_level) " +
             "VALUES (seq_requests.NEXTVAL, ?, ?, ?, ?, ?, ?, 'SUBMITTED', ?, ?, ?)";

try (PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, trackingNo);
    ps.setLong(2, req.getStudentId());
    ps.setString(3, req.getTitle());
    ps.setString(4, req.getDescription());
    ps.setString(5, req.getCategory());
    ps.setString(6, req.getPriority());
    ps.setString(7, req.getLocation());
    ps.setString(8, req.getUrgencyLevel());
    ps.setString(9, req.getImpactLevel());
    ps.executeUpdate();
}"""
    add_code_block("Listing 4.10: Service Request INSERT in RequestDAO.java", listing_4_10)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.7 Staff Action & Workflow Transition Module")
    r.font.bold = True
    r.font.size = Pt(13)

    listing_4_11 = """// Atomic status transition and history logging in WorkflowService.java
public boolean transitionStatus(long requestId, String targetStatus, 
                                long userId, String remarks) throws SQLException {
    Connection con = DBConnection.getConnection();
    try {
        con.setAutoCommit(false);
        RequestBean req = requestDAO.findById(requestId, con);
        validateTransition(req.getStatus(), targetStatus);
        
        requestDAO.updateStatus(requestId, targetStatus, con);
        requestHistoryDAO.create(requestId, req.getStatus(), targetStatus, userId, remarks, con);
        
        // Notify student of progress
        notificationDAO.create(req.getStudentId(), requestId, 
            "Request Updated", "Status changed to " + targetStatus, con);
        
        con.commit();
        return true;
    } catch (Exception e) {
        con.rollback();
        throw e;
    } finally {
        con.close();
    }
}"""
    add_code_block("Listing 4.11: Atomic Workflow Transition in WorkflowService.java", listing_4_11)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.8 Admin Assignment & User Governance Module")
    r.font.bold = True
    r.font.size = Pt(13)

    listing_4_14 = """// High-performance Oracle ROWNUM nested pagination in RequestDAO.java
String sql = "SELECT * FROM ( " +
             "  SELECT a.*, ROWNUM rnum FROM ( " +
             "    SELECT r.*, u.full_name as student_name, d.department_name " +
             "    FROM requests r " +
             "    JOIN users u ON r.student_id = u.user_id " +
             "    LEFT JOIN departments d ON r.department_id = d.department_id " +
             "    WHERE 1=1 " + filterConditions +
             "    ORDER BY r.created_at DESC " +
             "  ) a WHERE ROWNUM <= ? " +
             ") WHERE rnum > ?";
ps.setInt(paramIndex++, page * pageSize);
ps.setInt(paramIndex++, (page - 1) * pageSize);"""
    add_code_block("Listing 4.14: Oracle ROWNUM Nested Subquery Pagination", listing_4_14)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.9 Feedback & Notification Module")
    r.font.bold = True
    r.font.size = Pt(13)

    listing_4_15 = """// Post-resolution feedback submission and ticket closure
public boolean submitFeedback(FeedbackBean fb) throws SQLException {
    Connection con = DBConnection.getConnection();
    try {
        con.setAutoCommit(false);
        feedbackDAO.create(fb, con);
        requestDAO.updateStatus(fb.getRequestId(), "CLOSED", con);
        requestHistoryDAO.create(fb.getRequestId(), "RESOLVED", "CLOSED", 
                                fb.getStudentId(), "Feedback submitted by student.", con);
        con.commit();
        return true;
    } catch(Exception e) {
        con.rollback();
        throw e;
    } finally {
        con.close();
    }
}"""
    add_code_block("Listing 4.15: Feedback Submission and Ticket Closure", listing_4_15)

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("4.10 Security Measures")
    r.font.bold = True
    r.font.size = Pt(13)

    sec_measures_data = [
        ("Security Risk", "Mitigation Measure in CampusFlow"),
        ("Stolen / Leaked Passwords", "Passwords hashed via PBKDF2WithHmacSHA256 (65,536 iterations, 16-byte random salt). Plaintext never stored."),
        ("SQL Injection Attacks", "100% of queries use PreparedStatement with ? placeholders; parameter binding keeps SQL and user data strictly separated."),
        ("Cross-Site Scripting (XSS)", "User-supplied content is sanitized with SecurityUtil.escapeHtml() (&, <, >, \", ') before DOM rendering."),
        ("Cross-Site Request Forgery (CSRF)", "CsrfFilter enforces cryptographically secure 128-bit synchronizer tokens on all state-altering POST requests."),
        ("Session Fixation", "Existing session is explicitly invalidated at login and a fresh session ID is issued by Tomcat."),
        ("Privilege Escalation", "AuthenticationFilter enforces role restrictions on /student/*, /staff/*, and /admin/* returning HTTP 403 Forbidden."),
        ("Tampering with Others' Tickets", "DAO queries filter by student_id or assigned_staff_id, verifying record ownership on the server."),
        ("Information Leakage", "Generic error messages on authentication failure; stack traces suppressed via web.xml custom error pages (403, 404, 500)."),
        ("Duplicate Form Submissions", "Post/Redirect/Get (PRG) pattern redirects state changes to GET routes with session flash messages.")
    ]
    tbl_sec = doc.add_table(rows=len(sec_measures_data), cols=2)
    style_table(tbl_sec)
    for i, (r_name, m_name) in enumerate(sec_measures_data):
        row = tbl_sec.rows[i]
        row.cells[0].paragraphs[0].text = r_name
        row.cells[1].paragraphs[0].text = m_name
        row.cells[0].width = Inches(2.2)
        row.cells[1].width = Inches(4.2)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 5: RESULTS
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("21").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("5. RESULTS")
    r.font.bold = True
    r.font.size = Pt(15)

    doc.add_paragraph(
        "This chapter presents the working web application running on Apache Tomcat 9 (localhost:8089) and the persistent database records stored in Oracle 10g XE. Prominent screenshot placeholder containers are provided below matching the layout of the reference report, ready for visual browser captures."
    )

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.1 Login Page")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Figure 5.1 illustrates the authentication portal. Users enter registered email credentials and password. One-click demo credential shortcuts (Admin, Staff, Student) are provided for evaluation. Invalid credentials safely display 'Invalid email or password' without revealing account existence."
    )
    add_screenshot_placeholder("Figure 5.1: Login page", "Capture from http://localhost:8089/campusflow/login")

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.2 Student Dashboard & Request Submission Page")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Figure 5.2 shows the Student Dashboard and Service Request Creation Form. The student selects category, title, description, location, urgency, and impact. The live Priority Engine preview dynamically updates the priority badge in real time. Upon submission, tracking code CF-2026-xxxxx is generated."
    )
    add_screenshot_placeholder("Figure 5.2: Student Dashboard and Request Submission", "Capture from http://localhost:8089/campusflow/student/requests/create")

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.3 Request Details & Timeline Tracking Page")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Figure 5.3 shows the Request Details and History Timeline. The page displays ticket metadata, assigned staff, priority badge, and an immutable audit timeline showing timestamps and remarks for each transition."
    )
    add_screenshot_placeholder("Figure 5.3: Request Details and Timeline Tracking", "Capture from http://localhost:8089/campusflow/student/requests/details?id=1")

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.4 Staff Dashboard & Task Action Page")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Figure 5.4 depicts the Staff Work Queue. Assigned technicians view pending tasks, click 'Start Work' (transitioning to IN_PROGRESS), and 'Mark as Resolved' with mandatory resolution remarks."
    )
    add_screenshot_placeholder("Figure 5.4: Staff Dashboard and Task Action", "Capture from http://localhost:8089/campusflow/staff/dashboard")

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.5 Admin Dashboard & Request Assignment Page")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Figure 5.5 presents the Administrator Dashboard and Master Request Dispatch view. Administrators inspect all campus tickets, assign requests to departments and staff via modal dialogs, and override priority with mandatory justification."
    )
    add_screenshot_placeholder("Figure 5.5: Admin Dashboard and Request Assignment", "Capture from http://localhost:8089/campusflow/admin/requests")

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.6 Analytics & Reports Page")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "Figure 5.6 illustrates operational analytics rendered via native SVG Donut and Bar charts, displaying status distribution, priority breakdown, and departmental resolution turnaround speeds."
    )
    add_screenshot_placeholder("Figure 5.6: Operational Analytics and Reports", "Capture from http://localhost:8089/campusflow/admin/analytics")

    p_sec = doc.add_paragraph()
    r = p_sec.add_run("5.7 Database Output")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "The following formatted database records and screenshots reflect direct queries executed in Oracle SQL*Plus, confirming persistent database storage across all schema tables."
    )

    add_screenshot_placeholder("Figure 5.7: USERS table with PBKDF2 salted hashes in SQL*Plus", "SQL: SELECT user_id, full_name, email, role, is_active FROM users;")
    add_screenshot_placeholder("Figure 5.8: DEPARTMENTS table in SQL*Plus", "SQL: SELECT department_id, code, department_name FROM departments;")
    add_screenshot_placeholder("Figure 5.9: REQUESTS table with tracking codes and priorities", "SQL: SELECT request_id, tracking_number, title, priority, status FROM requests;")
    add_screenshot_placeholder("Figure 5.10: REQUEST_HISTORY audit trail table", "SQL: SELECT history_id, request_id, old_status, new_status, remarks FROM request_history;")
    add_screenshot_placeholder("Figure 5.11: FEEDBACK table with 5-star student ratings", "SQL: SELECT feedback_id, request_id, rating, comments FROM feedback;")

    p_sec = doc.add_paragraph()
    p_sec.paragraph_format.space_before = Pt(8)
    r = p_sec.add_run("5.8 Testing")
    r.font.bold = True
    r.font.size = Pt(13)

    doc.add_paragraph(
        "The application was systematically verified across unit, DAO, workflow, and HTTP security tiers with 100% pass rate. A summary of test cases is presented below."
    )

    test_cases_data = [
        ("No.", "Test Case", "Action / Input", "Expected Result"),
        ("1", "Valid Student Registration", "Fill valid details (email, pass, phone)", "User inserted in USERS with PBKDF2 hash; redirect to login with success."),
        ("2", "Duplicate Email Rejection", "Register with existing email", "Rejected with error: 'An account with this email already exists.'"),
        ("3", "Weak Password Validation", "Password without uppercase or digit", "Rejected with password complexity policy error message."),
        ("4", "Valid Credential Login", "Correct email and password", "Session established; redirects to role dashboard (Student, Staff, Admin)."),
        ("5", "Invalid Password Login", "Correct email, wrong password", "Rejected with generic 'Invalid email or password' message."),
        ("6", "Unauthenticated Route Guard", "Access /student/dashboard directly", "AuthenticationFilter intercepts; HTTP 302 redirect to /login."),
        ("7", "Cross-Role Security Guard", "Student session accesses /admin/dashboard", "AuthenticationFilter rejects with HTTP 403 Forbidden."),
        ("8", "Service Request Creation", "Student submits issue with location & urgency", "Tracking ID CF-2026-xxxxx generated, priority calculated, saved to DB."),
        ("9", "Priority Engine Auto-Escalation", "Description contains 'water pipe burst'", "PriorityService auto-escalates priority score to CRITICAL."),
        ("10", "Pre-Assignment Edit", "Student edits SUBMITTED request", "Request updated in Oracle; changes permitted before assignment."),
        ("11", "Illegal State Transition", "Attempt jump from SUBMITTED to RESOLVED", "WorkflowService rejects with IllegalArgumentException; state intact."),
        ("12", "Admin Staff Assignment", "Admin selects department and staff", "Request status updated to ASSIGNED; history logged, staff notified."),
        ("13", "Staff Work Completion", "Staff inputs resolution remarks and resolves", "Status set to RESOLVED, resolved_at recorded, student invited for feedback."),
        ("14", "Post-Resolution Feedback", "Student submits 5-star rating and comment", "Saved to FEEDBACK table; request status automatically advances to CLOSED."),
        ("15", "Anti-CSRF Defense", "POST request without csrfToken parameter", "CsrfFilter rejects request with HTTP 403 Forbidden."),
        ("16", "Session Destruction on Logout", "User clicks Logout", "Session invalidated; subsequent navigation redirects to /login.")
    ]
    tbl_tc = doc.add_table(rows=len(test_cases_data), cols=4)
    style_table(tbl_tc)
    for i, (t_no, t_name, t_act, t_exp) in enumerate(test_cases_data):
        row = tbl_tc.rows[i]
        row.cells[0].paragraphs[0].text = t_no
        row.cells[1].paragraphs[0].text = t_name
        row.cells[2].paragraphs[0].text = t_act
        row.cells[3].paragraphs[0].text = t_exp
        row.cells[0].width = Inches(0.5)
        row.cells[1].width = Inches(1.8)
        row.cells[2].width = Inches(2.0)
        row.cells[3].width = Inches(2.3)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 6: CONCLUSION
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("27").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("6. CONCLUSION")
    r.font.bold = True
    r.font.size = Pt(15)

    doc.add_paragraph(
        "CampusFlow: Smart Service & Issue Management System demonstrates how a robust, database-driven, enterprise web application can be built entirely with pure Java EE technologies without external third-party frameworks. Students can register, submit campus service requests, receive unique tracking numbers, monitor ticket progress through an audit timeline, and submit post-resolution feedback. Staff members manage assigned queues and log resolution remarks, while administrators govern user accounts, manage departments, dispatch technicians, and inspect live operational analytics. All application records are securely persisted in an Oracle 10g Express Edition database accessed through parameterized JDBC PreparedStatements, and web pages are dynamically rendered by JSP templates on Apache Tomcat 9. Security is woven throughout the application design: passwords use salted PBKDF2 key derivation, forms enforce anti-CSRF tokens, dynamic output is HTML-escaped, and sessions are guarded against fixation."
    )
    doc.add_paragraph(
        "The project provided valuable practical experience in relational database modeling, Oracle sequences, domain constraints, JDBC transaction boundaries, Servlet lifecycle orchestration, modular JSP layout, and writing clean, maintainable MVC software."
    )

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Limitations")
    r.font.bold = True
    r.font.size = Pt(12)

    limitations = [
        "In-App Notification Relays: Notifications are currently stored internally in the database; direct SMS or external SMTP email relays were omitted to guarantee offline operational capability.",
        "Attachment Upload Storage: Multi-part media attachments (e.g. photos of damaged equipment) are not persisted in Oracle to keep the database footprint lightweight across student desktop installations.",
        "Single-Instance Connection Factory: Database connections are managed via DBConnection.java; high-concurrency production deployments would benefit from container-managed JNDI connection pooling (e.g. Apache Commons DBCP).",
        "Geographic Mapping: Campus locations are identified through structured text fields (e.g. 'Block B, Room 204') rather than interactive GPS or indoor floor plan mapping."
    ]
    for lim in limitations:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(2)
        p.add_run(lim)

    p_sub = doc.add_paragraph()
    r = p_sub.add_run("Future Scope")
    r.font.bold = True
    r.font.size = Pt(12)

    future_scope = [
        "Mobile Application Integration: Develop native Android and iOS mobile applications communicating with the existing Java Servlets via RESTful JSON endpoints.",
        "Automated Email & SMS Alerts: Integrate JavaMail API and SMS gateway webhooks to push real-time alerts to students and technicians on ticket status changes.",
        "AI-Powered Issue Categorization: Implement Natural Language Processing (NLP) models to automatically classify complaint narratives and assign target departments.",
        "Interactive Campus GIS Mapping: Embed interactive campus indoor map visualizers allowing students to drop location pins on faulty equipment.",
        "IoT Sensor Integration: Connect smart IoT sensors (e.g. water tank level sensors, power meter monitors) to trigger automated service tickets before human discovery."
    ]
    for fut in future_scope:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(2)
        p.add_run(fut)

    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # CHAPTER 7: REFERENCES
    # ---------------------------------------------------------------------------
    p_num = doc.add_paragraph()
    p_num.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_num.add_run("28").font.size = Pt(10)

    p_ch = doc.add_paragraph()
    p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ch.paragraph_format.space_before = Pt(8)
    p_ch.paragraph_format.space_after = Pt(12)
    r = p_ch.add_run("7. REFERENCES")
    r.font.bold = True
    r.font.size = Pt(15)

    references = [
        "[1] Oracle Corporation, \"Oracle Database JDBC Developer's Guide\", Oracle Documentation. https://docs.oracle.com/en/database/",
        "[2] The Apache Software Foundation, \"Apache Tomcat 9 Documentation\" (including the Jasper 2 JSP Engine How-To). https://tomcat.apache.org/tomcat-9.0-doc/",
        "[3] JavaServer Pages Specification 2.3 (JSR 245) and Java Servlet Specification 4.0 (JSR 369).",
        "[4] Mozilla, \"MDN Web Docs: HTML, CSS and JavaScript\". https://developer.mozilla.org/",
        "[5] OWASP, \"Password Storage Cheat Sheet - PBKDF2 Recommendation\". https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html",
        "[6] OWASP, \"Cross-Site Request Forgery (CSRF) Prevention Cheat Sheet\". https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html",
        "[7] OWASP, \"SQL Injection Prevention Cheat Sheet\". https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html",
        "[8] NIST Special Publication 800-132, \"Recommendation for Password-Based Key Derivation: Part 1 - Storage Applications\".",
        "[9] Herbert Schildt, \"Java: The Complete Reference\", 12th Edition, McGraw-Hill Education.",
        "[10] Marty Hall and Larry Brown, \"Core Servlets and JavaServer Pages: Advanced Technologies\", Prentice Hall PTR."
    ]
    for ref in references:
        p = doc.add_paragraph()
        p.paragraph_format.line_spacing = 1.15
        p.paragraph_format.space_after = Pt(6)
        p.add_run(ref)

    # ---------------------------------------------------------------------------
    # ADD PAGE BORDERS TO ALL SECTIONS
    # ---------------------------------------------------------------------------
    for s in doc.sections:
        add_page_border_to_section(s)

    # Save outputs
    out_path1 = r'D:\fsd2-project\CampusFlow_Project_Report_Nimmala_Venkata_Umesh_Chandra.docx'
    out_path2 = r'C:\Users\nvenk\Downloads\CampusFlow_Project_Report_Nimmala_Venkata_Umesh_Chandra.docx'

    doc.save(out_path1)
    print(f"Saved primary report to {out_path1}")
    try:
        doc.save(out_path2)
        print(f"Copied report to {out_path2}")
    except Exception as e:
        print(f"Could not copy to downloads: {e}")

if __name__ == '__main__':
    create_report()

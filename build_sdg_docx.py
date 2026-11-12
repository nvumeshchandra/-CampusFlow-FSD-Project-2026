import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def create_sdg_document():
    doc = docx.Document()

    # Standard margins (0.65 in to match the 6-page layout cleanly)
    for section in doc.sections:
        section.top_margin = Inches(0.65)
        section.bottom_margin = Inches(0.65)
        section.left_margin = Inches(0.75)
        section.right_margin = Inches(0.75)

    # Base Normal Style
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Times New Roman'
    normal_style.font.size = Pt(11)
    normal_style.font.color.rgb = RGBColor(0, 0, 0)
    normal_style.paragraph_format.line_spacing = 1.15
    normal_style.paragraph_format.space_after = Pt(3)

    # Palette
    C_BLUE = RGBColor(31, 73, 125)    # #1F497D (Header & Titles)
    C_RED = RGBColor(192, 0, 0)       # #C00000 (AUTONOMOUS)
    C_BLACK = RGBColor(0, 0, 0)

    logo_path = r'D:\fsd2-project\extracted_media\word\media\image1.jpeg'

    def style_table(table, header_bg="EDF2F8", border_color="B0C4DE"):
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
        if header_bg:
            for cell in table.rows[0].cells:
                shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{header_bg}"/>')
                cell._tc.get_or_add_tcPr().append(shd)
                for p in cell.paragraphs:
                    for run in p.runs:
                        run.font.bold = True
                        run.font.name = 'Times New Roman'
                        run.font.size = Pt(10)

    def set_cell_margins(cell, top=60, bottom=60, left=100, right=100):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = parse_xml(
            f'<w:tcMar {nsdecls("w")}>\n'
            f'  <w:top w:w="{top}" w:type="dxa"/>\n'
            f'  <w:bottom w:w="{bottom}" w:type="dxa"/>\n'
            f'  <w:left w:w="{left}" w:type="dxa"/>\n'
            f'  <w:right w:w="{right}" w:type="dxa"/>\n'
            f'</w:tcMar>'
        )
        tcPr.append(tcMar)

    # ---------------------------------------------------------------------------
    # PAGE 1: HEADER & ACTIVITY SUMMARY
    # ---------------------------------------------------------------------------
    tbl_hdr = doc.add_table(rows=1, cols=2)
    tbl_hdr.alignment = WD_TABLE_ALIGNMENT.CENTER
    c_logo, c_text = tbl_hdr.rows[0].cells
    c_logo.width = Inches(1.1)
    c_text.width = Inches(5.9)

    tblPr = tbl_hdr._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>\n'
        f'  <w:top w:val="none"/>\n'
        f'  <w:bottom w:val="none"/>\n'
        f'  <w:left w:val="none"/>\n'
        f'  <w:right w:val="none"/>\n'
        f'  <w:insideH w:val="none"/>\n'
        f'  <w:insideV w:val="none"/>\n'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

    p_logo = c_logo.paragraphs[0]
    p_logo.alignment = WD_ALIGN_PARAGRAPH.LEFT
    if os.path.exists(logo_path):
        p_logo.add_run().add_picture(logo_path, width=Inches(0.95))

    p_info = c_text.paragraphs[0]
    p_info.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_info.paragraph_format.line_spacing = 1.1
    p_info.paragraph_format.space_after = Pt(0)
    
    r_col = p_info.add_run("LAKIREDDY BALI REDDY COLLEGE OF ENGINEERING\n")
    r_col.font.bold = True
    r_col.font.size = Pt(12)
    r_col.font.color.rgb = C_BLUE

    r_aut = p_info.add_run("(AUTONOMOUS)\n")
    r_aut.font.bold = True
    r_aut.font.size = Pt(10.5)
    r_aut.font.color.rgb = C_RED

    r_sub = p_info.add_run("Approved by AICTE, New Delhi and Permanently affiliated to JNTUK, Kakinada\n")
    r_sub.font.size = Pt(8)
    r_sub.font.bold = True
    r_sub.font.color.rgb = C_BLUE

    r_addr = p_info.add_run("L.B. Reddy Nagar, Mylavaram, N.T.R. District, Andhra Pradesh-521230")
    r_addr.font.size = Pt(8)
    r_addr.font.bold = True
    r_addr.font.color.rgb = C_BLUE

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(10)
    p_title.paragraph_format.space_after = Pt(2)
    r_main_title = p_title.add_run("PROJECT–SDG ALIGNMENT")
    r_main_title.font.bold = True
    r_main_title.font.size = Pt(13)
    r_main_title.font.color.rgb = C_BLUE

    p_sub_title = doc.add_paragraph()
    p_sub_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub_title.paragraph_format.space_after = Pt(8)
    r_sub_desc = p_sub_title.add_run("Programme Outcomes (POs) • Programme Specific Outcomes (PSOs) • Sustainable Development Goals (SDGs)")
    r_sub_desc.font.italic = True
    r_sub_desc.font.size = Pt(9.5)
    r_sub_desc.font.color.rgb = C_BLUE

    p_sec1 = doc.add_paragraph()
    p_sec1.paragraph_format.space_before = Pt(2)
    p_sec1.paragraph_format.space_after = Pt(3)
    r_s1 = p_sec1.add_run("Student and Subject Details")
    r_s1.font.bold = True
    r_s1.font.size = Pt(11)
    r_s1.font.color.rgb = C_BLUE

    student_details = [
        ("Student Name", "NIMMALA VENKATA UMESH CHANDRA"),
        ("Roll Number", "24761A05AD"),
        ("Year / Semester / Section", "III/V/F"),
        ("Department / Programme", "COMPUTER SCIENCE AND ENGINEERING"),
        ("Subject Name and Code", "Full Stack Development-II and 23CSS4"),
        ("Faculty Name", "N.SrinivasaRao"),
        ("Project Title / Assignment / Case Study", "CampusFlow: Smart Service & Issue Management System"),
        ("Technology / Tools Used", "HTML,CSS,JS,JAVA(JSP,Servlets,JDBC),Oracle")
    ]

    tbl_stud = doc.add_table(rows=len(student_details), cols=2)
    style_table(tbl_stud, header_bg=None)
    for i, (label, val) in enumerate(student_details):
        row = tbl_stud.rows[i]
        c1, c2 = row.cells
        c1.width = Inches(2.6)
        c2.width = Inches(4.4)
        set_cell_margins(c1, 40, 40, 80, 80)
        set_cell_margins(c2, 40, 40, 80, 80)
        
        p1 = c1.paragraphs[0]
        p1.paragraph_format.space_after = Pt(0)
        r1 = p1.add_run(label)
        r1.font.bold = True
        r1.font.size = Pt(9.5)
        
        p2 = c2.paragraphs[0]
        p2.paragraph_format.space_after = Pt(0)
        r2 = p2.add_run(val)
        r2.font.size = Pt(9.5)

    p_sec2 = doc.add_paragraph()
    p_sec2.paragraph_format.space_before = Pt(8)
    p_sec2.paragraph_format.space_after = Pt(3)
    r_s2 = p_sec2.add_run("Project / Subject Activity Summary")
    r_s2.font.bold = True
    r_s2.font.size = Pt(11)
    r_s2.font.color.rgb = C_BLUE

    p_p1 = doc.add_paragraph()
    p_p1.paragraph_format.space_before = Pt(2)
    p_p1.paragraph_format.space_after = Pt(2)
    r_h1 = p_p1.add_run("1. Problem statement / need addressed:")
    r_h1.font.bold = True
    r_h1.font.size = Pt(10)

    doc.add_paragraph(
        "In colleges and universities, students and teachers face daily problems like broken lights, faulty projector cables, lab computer issues, plumbing leaks, and broken desks. Currently, these complaints are written in manual paper logbooks or told verbally to staff. Because of this, complaints get lost, no tracking number is given, repair work gets delayed, and students have no idea when the problem will be solved. A central web application that lets students submit issues online, gives an instant tracking ID, calculates priority, and lets staff update progress directly in an Oracle database removes these everyday campus problems."
    )

    p_p2 = doc.add_paragraph()
    p_p2.paragraph_format.space_before = Pt(4)
    p_p2.paragraph_format.space_after = Pt(2)
    r_h2 = p_p2.add_run("2. Main objectives:")
    r_h2.font.bold = True
    r_h2.font.size = Pt(10)

    obj_items = [
        "1. To build a multi-page web application using pure HTML, CSS, JavaScript, JSP, and Java Servlets for handling campus service requests.",
        "2. To store users, departments, service requests, status history, and feedback in an Oracle relational database and access them safely using JDBC PreparedStatements.",
        "3. To provide secure student signup and login using PBKDF2 password hashing and HTTP sessions, with three clear roles: Student, Staff, and Admin.",
        "4. To calculate issue priority automatically using a smart rule-based engine (evaluating urgency, impact, and campus location) and generate unique tracking codes (CF-2026-xxxxx).",
        "5. To let staff members view their assigned task queue, update status to IN_PROGRESS, mark tickets as RESOLVED with remarks, and let students give 5-star ratings upon completion."
    ]
    for o in obj_items:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.left_indent = Inches(0.2)
        p.add_run(o).font.size = Pt(10)

    # END OF PAGE 1
    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 2: BRIEF DESCRIPTION, USERS, OUTCOMES, AND PO MAPPING (PO1 - PO4)
    # ---------------------------------------------------------------------------
    p_p3 = doc.add_paragraph()
    p_p3.paragraph_format.space_before = Pt(2)
    p_p3.paragraph_format.space_after = Pt(2)
    r_h3 = p_p3.add_run("3. Brief description of the solution and its key features:")
    r_h3.font.bold = True
    r_h3.font.size = Pt(10)

    doc.add_paragraph(
        "CampusFlow is a complete Java Fullstack web application running on Apache Tomcat 9 with an Oracle 10g Express database. Students log in, select the problem category (IT, Electrical, Plumbing, Infrastructure), specify the exact campus room or lab, and choose the urgency. The system immediately calculates the priority level (Low, Medium, High, Critical) and gives a unique tracking ID. Technicians see an organized list of assigned tasks, start work, and type resolution notes when finished. The administrator can see all campus requests on one screen, dispatch staff, change priorities, and view live charts showing department performance. After the issue is solved, students submit 5-star feedback, which automatically closes the ticket."
    )

    p_p4 = doc.add_paragraph()
    p_p4.paragraph_format.space_before = Pt(4)
    p_p4.paragraph_format.space_after = Pt(2)
    r_h4 = p_p4.add_run("4. Intended users / beneficiaries:")
    r_h4.font.bold = True
    r_h4.font.size = Pt(10)

    users_list = [
        "1. College Students and Faculty: Who need classroom, laboratory, or hostel facilities repaired quickly and want an easy way to track their requests online.",
        "2. Maintenance Staff and Technicians: (Electricians, IT hardware engineers, plumbers, carpenters) who get a clear daily work queue showing urgent tasks first.",
        "3. College Management and Administrators: Who can monitor campus maintenance speed, ensure accountability, and see which departments are performing best."
    ]
    for u in users_list:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.left_indent = Inches(0.2)
        p.add_run(u).font.size = Pt(10)

    p_p5 = doc.add_paragraph()
    p_p5.paragraph_format.space_before = Pt(4)
    p_p5.paragraph_format.space_after = Pt(2)
    r_h5 = p_p5.add_run("5. Expected or observed outcomes / evidence:")
    r_h5.font.bold = True
    r_h5.font.size = Pt(10)

    doc.add_paragraph(
        "The application was run and tested locally on Apache Tomcat 9 (port 8089) and Oracle 10g XE. During student signup, passwords are encrypted using salted PBKDF2 hashing before saving into the USERS table. When a student submits an issue, a record is created in the REQUESTS table with status SUBMITTED and a tracking code like CF-2026-xxxxx. Moving the status to ASSIGNED, IN_PROGRESS, and RESOLVED records every action in the REQUEST_HISTORY table with exact timestamps and remarks. All 6 Oracle tables (USERS, DEPARTMENTS, REQUESTS, REQUEST_HISTORY, FEEDBACK, NOTIFICATIONS) store live persistent data. A total of 55 automated and integration test cases passed with 100% success rate."
    )

    p_map_po = doc.add_paragraph()
    p_map_po.paragraph_format.space_before = Pt(6)
    p_map_po.paragraph_format.space_after = Pt(2)
    r_m_po = p_map_po.add_run("Mapping with Programme Outcomes (POs)")
    r_m_po.font.bold = True
    r_m_po.font.size = Pt(11)
    r_m_po.font.color.rgb = C_BLUE

    p_inst_po = doc.add_paragraph()
    p_inst_po.paragraph_format.space_after = Pt(4)
    r_inst = p_inst_po.add_run("Instructions: Select only the POs meaningfully demonstrated by the work. Describe the specific activity, design decision, analysis, or evidence supporting each mapping.")
    r_inst.font.italic = True
    r_inst.font.size = Pt(9)

    po_data_p2 = [
        ("PO No.", "Relevant PO", "How the work demonstrates this PO"),
        ("PO1", "Engineering knowledge", "Applied fundamental computer science concepts: Java EE web architecture (Servlets, JSP), JDBC database connection, SQL queries, relational database design with primary and foreign keys, and Oracle sequences to build a complete database-driven web system."),
        ("PO2", "Problem analysis", "Analyzed the daily problems of college facility maintenance and identified all necessary data entities (users, departments, service requests, status history, feedback, notifications), their relationships, and the step-by-step actions performed by each user role."),
        ("PO3", "Design/development of solutions", "Designed a three-tier MVC architecture (web browser, Tomcat server with JSP/Servlets, Oracle database) with 6 related tables. Developed modules for user registration, login, issue submission, staff task actions, priority calculation, and dynamic analytics."),
        ("PO4", "Conduct investigations of complex problems", "Not mapped for this project.")
    ]
    tbl_po1 = doc.add_table(rows=len(po_data_p2), cols=3)
    style_table(tbl_po1)
    for i, (c1, c2, c3) in enumerate(po_data_p2):
        row = tbl_po1.rows[i]
        row.cells[0].paragraphs[0].text = c1
        row.cells[1].paragraphs[0].text = c2
        row.cells[2].paragraphs[0].text = c3
        row.cells[0].width = Inches(0.9)
        row.cells[1].width = Inches(2.2)
        row.cells[2].width = Inches(3.9)
        set_cell_margins(row.cells[0], 35, 35, 60, 60)
        set_cell_margins(row.cells[1], 35, 35, 60, 60)
        set_cell_margins(row.cells[2], 35, 35, 60, 60)
        for p in row.cells[2].paragraphs:
            for r in p.runs:
                r.font.size = Pt(9.5)

    # END OF PAGE 2
    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 3: PO MAPPING CONTINUED (PO5 - PO11) & PSO MAPPING (PSO1)
    # ---------------------------------------------------------------------------
    po_data_p3 = [
        ("PO No.", "Relevant PO", "How the work demonstrates this PO"),
        ("PO5", "Engineering Tool Usage", "Used standard development tools: Eclipse IDE / VS Code for writing code, Apache Tomcat 9 as the servlet container, Oracle 10g XE with SQL*Plus for managing tables, Oracle JDBC Thin Driver (ojdbc14.jar), and JDK 17 for compilation and running tests."),
        ("PO6", "The Engineer and the World", "The project meets a direct campus community need by connecting students and teachers with college maintenance staff, making complaint tracking fast and transparent, and preventing physical safety hazards like water leaks and electrical sparks."),
        ("PO7", "Ethics", "Protects user privacy and data security: passwords are never stored in plain text and are hashed using salted PBKDF2; SQL injection is stopped by using PreparedStatement; XSS is prevented by escaping HTML text; and students can view and cancel only their own requests."),
        ("PO8", "Individual and Collaborative Team Work", "Not mapped for this project."),
        ("PO9", "Communication", "Documented the entire project in a clear technical report with architecture diagrams, ER diagrams, code listings, screenshots, and test cases. The website provides clear on-screen messages and confirmation alerts for every user action."),
        ("PO10", "Project management and finance", "Planned and completed the work in organized steps (database schema design, connection setup, user signup, login, request creation, staff workflow, admin dispatch, testing). Used 100% free open-source and express tools, so the project has zero software license cost."),
        ("PO11", "Life-long learning", "Learned practical enterprise web development skills independently: Oracle sequences and triggers, JDBC transactions, PBKDF2 password derivation, session fixation prevention, and fixing port conflicts between Oracle XE and Tomcat.")
    ]
    tbl_po2 = doc.add_table(rows=len(po_data_p3), cols=3)
    style_table(tbl_po2)
    for i, (c1, c2, c3) in enumerate(po_data_p3):
        row = tbl_po2.rows[i]
        row.cells[0].paragraphs[0].text = c1
        row.cells[1].paragraphs[0].text = c2
        row.cells[2].paragraphs[0].text = c3
        row.cells[0].width = Inches(0.9)
        row.cells[1].width = Inches(2.2)
        row.cells[2].width = Inches(3.9)
        set_cell_margins(row.cells[0], 35, 35, 60, 60)
        set_cell_margins(row.cells[1], 35, 35, 60, 60)
        set_cell_margins(row.cells[2], 35, 35, 60, 60)
        for p in row.cells[2].paragraphs:
            for r in p.runs:
                r.font.size = Pt(9.5)

    p_map_pso = doc.add_paragraph()
    p_map_pso.paragraph_format.space_before = Pt(8)
    p_map_pso.paragraph_format.space_after = Pt(2)
    r_m_pso = p_map_pso.add_run("Mapping with Programme Specific Outcomes (PSOs)")
    r_m_pso.font.bold = True
    r_m_pso.font.size = Pt(11)
    r_m_pso.font.color.rgb = C_BLUE

    p_inst_pso = doc.add_paragraph()
    p_inst_pso.paragraph_format.space_after = Pt(4)
    r_inst2 = p_inst_pso.add_run("Instructions: Select the PSOs demonstrated by the work and explain the connection to the approved programme-specific outcome.")
    r_inst2.font.italic = True
    r_inst2.font.size = Pt(9)

    pso_data_p3 = [
        ("PSO No.", "How the work demonstrates this PSO"),
        ("PSO1: The ability to apply Software Engineering practices and strategies in software project development using open-source programming environment for the success of organization.",
         "Followed a standard software engineering lifecycle: requirements gathering, system design, database modeling, coding, unit testing, and documentation using open-source tools: Java 17, Apache Tomcat 9, Eclipse, and Oracle 10g XE. The code is modularized into JavaBeans, DAOs, Servlets, and JSP views, and verified with 55 automated test cases.")
    ]
    tbl_pso1 = doc.add_table(rows=len(pso_data_p3), cols=2)
    style_table(tbl_pso1)
    for i, (c1, c2) in enumerate(pso_data_p3):
        row = tbl_pso1.rows[i]
        row.cells[0].paragraphs[0].text = c1
        row.cells[1].paragraphs[0].text = c2
        row.cells[0].width = Inches(3.1)
        row.cells[1].width = Inches(3.9)
        set_cell_margins(row.cells[0], 40, 40, 70, 70)
        set_cell_margins(row.cells[1], 40, 40, 70, 70)
        for p in row.cells[1].paragraphs:
            for r in p.runs:
                r.font.size = Pt(9.5)

    # END OF PAGE 3
    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 4: PSO CONTINUED (PSO2, PSO3) & SDG MAPPING (SDG 1 - SDG 3)
    # ---------------------------------------------------------------------------
    pso_data_p4 = [
        ("PSO No.", "How the work demonstrates this PSO"),
        ("PSO2: The ability to design and develop computer programs in networking, web applications and IoT as per the society needs.",
         "Designed and developed a complete, responsive full-stack web application using HTML5, modern CSS3, JavaScript, JSP, and Java Servlets on Tomcat that meets an authentic educational institution need: digitizing, organizing, and tracking campus service issues."),
        ("PSO3: To inculcate an ability to analyze, design and implement database applications.",
         "Designed 6 interrelated Oracle database tables with primary keys, foreign keys, sequences, and check constraints. Implemented database queries through JDBC PreparedStatements, including multi-table joins, nested ROWNUM subquery pagination, and transaction rollbacks on failure.")
    ]
    tbl_pso2 = doc.add_table(rows=len(pso_data_p4), cols=2)
    style_table(tbl_pso2)
    for i, (c1, c2) in enumerate(pso_data_p4):
        row = tbl_pso2.rows[i]
        row.cells[0].paragraphs[0].text = c1
        row.cells[1].paragraphs[0].text = c2
        row.cells[0].width = Inches(3.1)
        row.cells[1].width = Inches(3.9)
        set_cell_margins(row.cells[0], 40, 40, 70, 70)
        set_cell_margins(row.cells[1], 40, 40, 70, 70)
        for p in row.cells[1].paragraphs:
            for r in p.runs:
                r.font.size = Pt(9.5)

    p_map_sdg = doc.add_paragraph()
    p_map_sdg.paragraph_format.space_before = Pt(10)
    p_map_sdg.paragraph_format.space_after = Pt(2)
    r_m_sdg = p_map_sdg.add_run("Mapping with Sustainable Development Goals (SDGs)")
    r_m_sdg.font.bold = True
    r_m_sdg.font.size = Pt(11)
    r_m_sdg.font.color.rgb = C_BLUE

    p_inst_sdg = doc.add_paragraph()
    p_inst_sdg.paragraph_format.space_after = Pt(4)
    r_inst3 = p_inst_sdg.add_run("Instructions: Review the 17 SDGs below. Select the one or more goals that are directly supported by the project. For each selected goal, explain the specific feature or outcome and provide evidence where possible. Do not claim an SDG connection based only on the project title. (Select at Max: 3 to 4 SDGs)")
    r_inst3.font.italic = True
    r_inst3.font.size = Pt(9)

    sdg_data_p4 = [
        ("Select (✓)", "SDG No.", "Official goal title", "Reason for selection / project contribution"),
        ("☐", "SDG 1", "No Poverty", ""),
        ("☐", "SDG 2", "Zero Hunger", ""),
        ("☐", "SDG 3", "Good Health and Well-being", "")
    ]
    tbl_sdg1 = doc.add_table(rows=len(sdg_data_p4), cols=4)
    style_table(tbl_sdg1)
    for i, (c1, c2, c3, c4) in enumerate(sdg_data_p4):
        row = tbl_sdg1.rows[i]
        row.cells[0].paragraphs[0].text = c1
        row.cells[1].paragraphs[0].text = c2
        row.cells[2].paragraphs[0].text = c3
        row.cells[3].paragraphs[0].text = c4
        row.cells[0].width = Inches(0.9)
        row.cells[1].width = Inches(0.9)
        row.cells[2].width = Inches(2.3)
        row.cells[3].width = Inches(2.9)
        set_cell_margins(row.cells[0], 35, 35, 50, 50)
        set_cell_margins(row.cells[1], 35, 35, 50, 50)
        set_cell_margins(row.cells[2], 35, 35, 50, 50)
        set_cell_margins(row.cells[3], 35, 35, 50, 50)

    # END OF PAGE 4
    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 5: SDG MAPPING CONTINUED (SDG 4 - SDG 17) & PRIMARY/SECONDARY SDGS
    # ---------------------------------------------------------------------------
    sdg_data_p5 = [
        ("Select (✓)", "SDG No.", "Official goal title", "Reason for selection / project contribution"),
        ("☑", "SDG 4", "Quality Education", "Ensures that classroom audiovisual systems, laboratory computers, air conditioning, and electrical fittings are maintained and repaired promptly without prolonged downtime, ensuring students and teachers have an uninterrupted, high-quality learning environment."),
        ("☐", "SDG 5", "Gender Equality", ""),
        ("☐", "SDG 6", "Clean Water and Sanitation", ""),
        ("☐", "SDG 7", "Affordable and Clean Energy", ""),
        ("☐", "SDG 8", "Decent Work and Economic Growth", ""),
        ("☑", "SDG 9", "Industry, Innovation and Infrastructure", "Builds a modern digital infrastructure (three-tier Java web application backed by an Oracle database) that replaces outdated paper registers with automated ticket generation, a rule-based priority engine, and live administrative analytics using free open-source tools."),
        ("☐", "SDG 10", "Reduced Inequalities", ""),
        ("☑", "SDG 11", "Sustainable Cities and Communities", "Improves physical campus safety and sustainability by allowing students to report water pipeline leaks, loose electrical wires, and broken furniture quickly. This supports proactive campus maintenance and prevents accidents."),
        ("☐", "SDG 12", "Responsible Consumption and Production", ""),
        ("☐", "SDG 13", "Climate Action", ""),
        ("☐", "SDG 14", "Life Below Water", ""),
        ("☐", "SDG 15", "Life on Land", ""),
        ("☐", "SDG 16", "Peace, Justice and Strong Institutions", ""),
        ("☐", "SDG 17", "Partnerships for the Goals", "")
    ]
    tbl_sdg2 = doc.add_table(rows=len(sdg_data_p5), cols=4)
    style_table(tbl_sdg2)
    for i, (c1, c2, c3, c4) in enumerate(sdg_data_p5):
        row = tbl_sdg2.rows[i]
        row.cells[0].paragraphs[0].text = c1
        row.cells[1].paragraphs[0].text = c2
        row.cells[2].paragraphs[0].text = c3
        row.cells[3].paragraphs[0].text = c4
        row.cells[0].width = Inches(0.9)
        row.cells[1].width = Inches(0.9)
        row.cells[2].width = Inches(2.3)
        row.cells[3].width = Inches(2.9)
        set_cell_margins(row.cells[0], 25, 25, 50, 50)
        set_cell_margins(row.cells[1], 25, 25, 50, 50)
        set_cell_margins(row.cells[2], 25, 25, 50, 50)
        set_cell_margins(row.cells[3], 25, 25, 50, 50)
        if c1 == "☑":
            row.cells[0].paragraphs[0].runs[0].font.bold = True
            row.cells[0].paragraphs[0].runs[0].font.color.rgb = RGBColor(0, 128, 0)
        for p in row.cells[3].paragraphs:
            for r in p.runs:
                r.font.size = Pt(9)

    p_sdg_summary = doc.add_paragraph()
    p_sdg_summary.paragraph_format.space_before = Pt(6)
    p_sdg_summary.paragraph_format.space_after = Pt(2)
    r1 = p_sdg_summary.add_run("Primary SDG (if applicable): ")
    r1.font.bold = True
    r1.font.size = Pt(10)
    p_sdg_summary.add_run("SDG 4 – Quality Education\n").font.size = Pt(10)
    
    r2 = p_sdg_summary.add_run("Secondary SDG(s): ")
    r2.font.bold = True
    r2.font.size = Pt(10)
    p_sdg_summary.add_run("SDG 9 – Industry, Innovation and Infrastructure; SDG 11 – Sustainable Cities and Communities\n\n").font.size = Pt(10)

    r3 = p_sdg_summary.add_run("Specific project feature(s) linked to the selected SDG(s):\n")
    r3.font.bold = True
    r3.font.size = Pt(10)
    r_spec = p_sdg_summary.add_run(
        "SDG 4 and SDG 11: The student request creation form allows quick reporting of broken lab computers, projectors, water leaks, and electrical issues with room locations. The priority engine calculates issue urgency so critical classroom repairs are handled first. The staff queue ensures technicians fix problems on time and record remarks, while student 5-star ratings maintain service quality across all college blocks. SDG 9: The robust three-tier Java EE architecture (Servlets, JSP, JDBC, Oracle 10g XE) acts as the modern digital backbone replacing slow, unreliable manual registers with automated unique tracking codes (CF-2026-xxxxx), salted PBKDF2 authentication, and live SVG charts for administrative monitoring."
    )
    r_spec.font.size = Pt(9.5)

    # END OF PAGE 5
    doc.add_page_break()

    # ---------------------------------------------------------------------------
    # PAGE 6: MEASURABLE CONTRIBUTION & STUDENT DECLARATION
    # ---------------------------------------------------------------------------
    p_meas = doc.add_paragraph()
    p_meas.paragraph_format.space_before = Pt(4)
    p_meas.paragraph_format.space_after = Pt(2)
    r_m_title = p_meas.add_run("Measurable or verifiable contribution (if available):")
    r_m_title.font.bold = True
    r_m_title.font.size = Pt(10)

    doc.add_paragraph(
        "In the verified database implementation, 8 college departments (IT, Electrical, Plumbing, Infrastructure, etc.) are pre-configured. Multiple service requests were submitted, assigned, and transitioned through SUBMITTED, ASSIGNED, IN_PROGRESS, RESOLVED, and CLOSED states. The rule-based priority engine successfully auto-escalated emergency hazard keywords (like 'water pipe burst' and 'electrical spark') to CRITICAL priority. The home and admin dashboards calculate real-time statistics: total requests, open issues, critical tickets, and resolution rates directly from Oracle SQL count queries. 55 automated backend and HTTP security tests verified 100% persistence and route authorization."
    )

    p_dec_title = doc.add_paragraph()
    p_dec_title.paragraph_format.space_before = Pt(24)
    p_dec_title.paragraph_format.space_after = Pt(4)
    r_dt = p_dec_title.add_run("Student Declaration")
    r_dt.font.bold = True
    r_dt.font.size = Pt(11.5)
    r_dt.font.color.rgb = C_BLUE

    doc.add_paragraph(
        "I, NIMMALA VENKATA UMESH CHANDRA, bearing Roll No. 24761A05AD, declare that the information provided in this template accurately describes my work and its relationship to the selected Programme Outcomes, Programme Specific Outcomes, and Sustainable Development Goals. The SDG mappings are based on the project’s actual objectives, features, and expected or demonstrated outcomes."
    )

    p_sig_block = doc.add_paragraph()
    p_sig_block.paragraph_format.space_before = Pt(48)
    r_sig = p_sig_block.add_run("Student Signature: ____________________          Date: _______________")
    r_sig.font.bold = True

    # Output file paths
    out_path1 = r'D:\fsd2-project\CampusFlow_Project_SDG_Alignment_Nimmala_Venkata_Umesh_Chandra.docx'
    out_path2 = r'C:\Users\nvenk\Downloads\CampusFlow_Project_SDG_Alignment_Nimmala_Venkata_Umesh_Chandra.docx'

    doc.save(out_path1)
    print(f"Saved primary SDG docx to: {out_path1}")
    try:
        doc.save(out_path2)
        print(f"Copied SDG docx to: {out_path2}")
    except Exception as e:
        print(f"Error copying to downloads: {e}")

if __name__ == '__main__':
    create_sdg_document()

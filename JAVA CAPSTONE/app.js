/* ==========================================================================
   SIMATS Engineering - Skill Progress Analytics
   Clientside Controller & State Management
   ========================================================================== */

let currentStudentId = 1;
let currentStudentsList = [];
let subjectChartInstance = null;
let progressChartInstance = null;
let currentQuizQuestion = null;

// Initialization on DOM ready
document.addEventListener("DOMContentLoaded", () => {
  initApp();
});

async function initApp() {
  await loadStudentsList();
  await loadDashboardData();
  showDiagram('usecase'); // Initial UML diagram
}

// --------------------------------------------------------------------------
// Navigation & Theme Management
// --------------------------------------------------------------------------
function switchTab(tabId) {
  document.querySelectorAll(".tab-content").forEach(el => el.classList.remove("active"));
  document.querySelectorAll(".tab-btn").forEach(el => el.classList.remove("active"));

  const targetView = document.getElementById(`view-${tabId}`);
  const targetTabBtn = document.getElementById(`tab-${tabId}`);

  if (targetView) targetView.classList.add("active");
  if (targetTabBtn) targetTabBtn.classList.add("active");

  if (tabId === 'dashboard') {
    loadDashboardData();
  } else if (tabId === 'courses') {
    loadCoursesData();
  } else if (tabId === 'analytics') {
    loadAnalyticsData();
  } else if (tabId === 'recommendations') {
    loadRecommendationsData();
  } else if (tabId === 'report') {
    loadReportData();
  }
}

function toggleTheme() {
  const html = document.documentElement;
  const current = html.getAttribute("data-theme") || "light";
  const next = current === "light" ? "dark" : "light";
  html.setAttribute("data-theme", next);
  document.getElementById("themeToggleBtn").innerText = next === "dark" ? "☀️" : "🌙";
  
  if (subjectChartInstance) renderCharts();
}

function showToast(msg) {
  const toast = document.getElementById("toastNotification");
  const msgEl = document.getElementById("toastMessage");
  msgEl.innerText = msg;
  toast.style.display = "block";
  setTimeout(() => { toast.style.display = "none"; }, 3500);
}

// --------------------------------------------------------------------------
// Student Selection & Profile Management
// --------------------------------------------------------------------------
async function loadStudentsList() {
  try {
    const res = await fetch("/api/students");
    const data = await res.json();
    currentStudentsList = data.students || [];

    const select = document.getElementById("studentSelector");
    select.innerHTML = "";
    currentStudentsList.forEach(s => {
      const opt = document.createElement("option");
      opt.value = s.id;
      opt.innerText = `${s.name} (${s.regNo})`;
      if (s.id === currentStudentId) opt.selected = true;
      select.appendChild(opt);
    });
  } catch (e) {
    console.error("Failed to load students:", e);
  }
}

function onStudentChange(studentId) {
  currentStudentId = parseInt(studentId);
  loadDashboardData();
  showToast(`Switched to student profile ID #${studentId}`);
}

// --------------------------------------------------------------------------
// Module 1 & 2: Dashboard & Progress Analytics (Slide 7)
// --------------------------------------------------------------------------
async function loadDashboardData() {
  try {
    const res = await fetch(`/api/dashboard?studentId=${currentStudentId}`);
    const data = await res.json();

    if (data.error) {
      showToast("Error: " + data.error);
      return;
    }

    // Update KPI cards
    document.getElementById("kpiTotalStudents").innerText = data.summary.totalStudents || "1";
    document.getElementById("kpiTotalSubjects").innerText = data.summary.totalSubjects || "6";
    document.getElementById("kpiAverageScore").innerText = `${data.summary.averageScore}%`;
    document.getElementById("kpiWeakSubjects").innerText = data.summary.weakSubjectsCount || "0";

    // Populate Registered Students Table (Slide 7)
    const tbody = document.getElementById("registeredStudentsTableBody");
    tbody.innerHTML = "";
    currentStudentsList.forEach((st, idx) => {
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${st.id}</td>
        <td><strong>${st.name}</strong></td>
        <td>${st.email}</td>
        <td><span class="badge" style="background: var(--bg-card-subtle);">${st.department}</span></td>
        <td>
          <button class="btn btn-outline" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;" onclick="viewStudentReport(${st.id})">
            📄 View Report
          </button>
        </td>
      `;
      tbody.appendChild(tr);
    });

    // Render Charts
    renderCharts(data.progress, data.summary.averageProgress);
  } catch (e) {
    console.error("Failed to load dashboard data:", e);
  }
}

function renderCharts(progressList = [], avgProgress = 70.0) {
  const isDark = document.documentElement.getAttribute("data-theme") === "dark";
  const textColor = isDark ? "#e2e8f0" : "#475569";
  const gridColor = isDark ? "#334155" : "#e2e8f0";

  // 1. Subject Performance Bar Chart (Slide 7)
  const labels = progressList.map(p => p.courseName);
  const scores = progressList.map(p => p.score);
  const barColors = scores.map(s => {
    if (s >= 75) return '#3b82f6'; // Strong (Blue)
    if (s >= 60) return '#60a5fa'; // Average (Light Blue)
    return '#f87171';              // Weak (Red/Pink highlight)
  });

  const ctxBar = document.getElementById("subjectPerformanceChart").getContext("2d");
  if (subjectChartInstance) subjectChartInstance.destroy();

  subjectChartInstance = new Chart(ctxBar, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Subject Score (%)',
        data: scores,
        backgroundColor: barColors,
        borderRadius: 6,
        borderWidth: 1,
        borderColor: 'transparent'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (ctx) => ` Score: ${ctx.parsed.y}%`
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          max: 100,
          ticks: { color: textColor, callback: (v) => v + '%' },
          grid: { color: gridColor }
        },
        x: {
          ticks: { color: textColor, font: { size: 11 } },
          grid: { display: false }
        }
      }
    }
  });

  // 2. Overall Progress Donut Chart (Slide 7)
  const ctxDonut = document.getElementById("overallProgressChart").getContext("2d");
  if (progressChartInstance) progressChartInstance.destroy();

  progressChartInstance = new Chart(ctxDonut, {
    type: 'doughnut',
    data: {
      labels: ['Completed Progress', 'Remaining Syllabus'],
      datasets: [{
        data: [avgProgress, Math.max(0, 100 - avgProgress)],
        backgroundColor: ['#0284c7', '#e2e8f0'],
        hoverBackgroundColor: ['#0369a1', '#cbd5e1'],
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: '70%',
      plugins: {
        legend: {
          position: 'bottom',
          labels: { color: textColor, font: { size: 12 } }
        },
        tooltip: {
          callbacks: {
            label: (ctx) => ` ${ctx.label}: ${ctx.parsed}%`
          }
        }
      }
    }
  });
}

// --------------------------------------------------------------------------
// Course Management & Interactive Quiz Module (Slide 4, 5, 11)
// --------------------------------------------------------------------------
async function loadCoursesData() {
  try {
    const [coursesRes, progRes] = await fetchAll(["/api/courses", `/api/dashboard?studentId=${currentStudentId}`]);
    const courses = coursesRes.courses || [];
    const progressList = progRes.progress || [];

    const container = document.getElementById("coursesGridContainer");
    container.innerHTML = "";

    courses.forEach(c => {
      const p = progressList.find(pr => pr.courseId === c.id) || { score: 0, progress: 0, status: 'Enrolled' };
      const statusClass = p.status === 'Strong' ? 'badge-strong' : (p.status === 'Average' ? 'badge-average' : 'badge-weak');

      const card = document.createElement("div");
      card.className = "course-card";
      card.innerHTML = `
        <div>
          <div class="course-header">
            <span class="course-code">${c.code}</span>
            <span class="badge ${statusClass}">${p.status}</span>
          </div>
          <h4>${c.title}</h4>
          <p class="course-desc">${c.description}</p>
          
          <div class="progress-bar-container">
            <div class="progress-bar-label">
              <span>Syllabus Completion</span>
              <span>${p.progress}%</span>
            </div>
            <div class="progress-bar-track">
              <div class="progress-bar-fill" style="width: ${p.progress}%;"></div>
            </div>
          </div>

          <div style="font-size: 0.85rem; margin-bottom: 1rem; color: var(--text-muted);">
            <strong>Score:</strong> <span style="color: var(--text-main); font-weight: 700;">${p.score}%</span> • 
            <strong>Modules:</strong> ${c.totalModules} Units • 
            <strong>Credits:</strong> ${c.credits}
          </div>
        </div>

        <button class="btn btn-primary" style="width: 100%;" onclick="openQuizModal(${c.id}, '${c.title}')">
          ✍️ Take Interactive Quiz
        </button>
      `;
      container.appendChild(card);
    });
  } catch (e) {
    console.error("Failed to load courses:", e);
  }
}

async function openQuizModal(courseId, courseTitle) {
  try {
    const res = await fetch(`/api/quizzes?courseId=${courseId}`);
    const data = await res.json();
    const questions = data.questions || [];

    if (questions.length === 0) {
      showToast("No active quizzes found for this module.");
      return;
    }

    currentQuizQuestion = questions[0];
    document.getElementById("quizModalTitle").innerText = `Interactive Quiz: ${courseTitle}`;
    
    const body = document.getElementById("quizQuestionBody");
    body.innerHTML = `
      <div style="margin-bottom: 1rem;">
        <span class="badge badge-strong">${currentQuizQuestion.topic}</span>
        <h4 style="margin-top: 0.75rem; font-size: 1.05rem; line-height: 1.4;">${currentQuizQuestion.questionText}</h4>
      </div>

      <div style="display: flex; flex-direction: column; gap: 0.6rem; margin-bottom: 1.5rem;" id="quizOptionsList">
        ${currentQuizQuestion.options.map((opt, idx) => `
          <label style="display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem; border: 1px solid var(--border-color); border-radius: var(--radius-md); cursor: pointer; transition: var(--transition);" class="quiz-opt-label">
            <input type="radio" name="quizOpt" value="${idx}">
            <span style="font-size: 0.9rem;">${opt}</span>
          </label>
        `).join('')}
      </div>

      <div id="quizFeedbackBox" style="display: none; padding: 0.85rem; border-radius: var(--radius-md); margin-bottom: 1rem; font-size: 0.85rem;"></div>

      <div style="display: flex; justify-content: flex-end; gap: 0.75rem;">
        <button class="btn btn-outline" onclick="closeQuizModal()">Cancel</button>
        <button class="btn btn-primary" onclick="submitQuizAnswer(${courseId})">Submit Answer</button>
      </div>
    `;

    document.getElementById("quizModal").classList.add("active");
  } catch (e) {
    console.error("Quiz load error:", e);
  }
}

async function submitQuizAnswer(courseId) {
  const selected = document.querySelector('input[name="quizOpt"]:checked');
  if (!selected) {
    alert("Please select an option before submitting.");
    return;
  }

  const selectedIdx = parseInt(selected.value);
  try {
    const res = await fetch("/api/quizzes/submit", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        studentId: currentStudentId,
        courseId: courseId,
        questionId: currentQuizQuestion.id,
        selectedOption: selectedIdx
      })
    });

    const result = await res.json();
    const fbBox = document.getElementById("quizFeedbackBox");
    fbBox.style.display = "block";
    fbBox.style.background = result.isCorrect ? "var(--success-bg)" : "var(--danger-bg)";
    fbBox.style.color = result.isCorrect ? "var(--success-text)" : "var(--danger-text)";
    fbBox.innerHTML = `
      <strong>${result.isCorrect ? "✅ Correct!" : "❌ Incorrect"}</strong>
      <p style="margin-top: 0.35rem;">${result.explanation}</p>
      <p style="margin-top: 0.35rem; font-style: italic;">${result.message}</p>
    `;

    showToast("Quiz submitted & Skill Progress updated in Database!");
    setTimeout(() => {
      closeQuizModal();
      loadDashboardData();
    }, 2500);
  } catch (e) {
    console.error("Submission failed:", e);
  }
}

function closeQuizModal() {
  document.getElementById("quizModal").classList.remove("active");
}

// --------------------------------------------------------------------------
// Module 2: Progress & Skill Analytics (Slide 5)
// --------------------------------------------------------------------------
async function loadAnalyticsData() {
  try {
    const res = await fetch(`/api/skills?studentId=${currentStudentId}`);
    const data = await res.json();
    const skills = data.skills || [];

    const container = document.getElementById("skillsGridContainer");
    container.innerHTML = "";

    skills.forEach(s => {
      const perfClass = s.performance === 'Strong' ? 'strong-border' : (s.performance === 'Average' ? 'average-border' : 'weak-border');
      const badgeClass = s.performance === 'Strong' ? 'badge-strong' : (s.performance === 'Average' ? 'badge-average' : 'badge-weak');

      const card = document.createElement("div");
      card.className = `skill-card ${perfClass}`;
      card.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem;">
          <h3 style="font-size: 1.15rem;">${s.subject}</h3>
          <span class="badge ${badgeClass}">${s.performance} (${s.score}%)</span>
        </div>

        <div style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.75rem;">
          <strong>Mastery Status:</strong> ${s.masteryLevel}
        </div>

        <div style="margin-bottom: 0.75rem;">
          <strong style="font-size: 0.8rem; color: var(--success-text);">Identified Strengths:</strong>
          <div class="tag-list">
            ${s.strengths.map(st => `<span class="tag">✓ ${st}</span>`).join('')}
          </div>
        </div>

        ${s.weakTopics.length > 0 ? `
          <div>
            <strong style="font-size: 0.8rem; color: var(--danger-text);">Weak Topics for Revision:</strong>
            <div class="tag-list">
              ${s.weakTopics.map(w => `<span class="tag tag-weak">⚠️ ${w}</span>`).join('')}
            </div>
          </div>
        ` : ''}
      `;
      container.appendChild(card);
    });
  } catch (e) {
    console.error("Failed to load skills:", e);
  }
}

// --------------------------------------------------------------------------
// Module 3: Personalized Recommendation Engine (Slide 6)
// --------------------------------------------------------------------------
async function loadRecommendationsData() {
  try {
    const res = await fetch(`/api/recommendations?studentId=${currentStudentId}`);
    const data = await res.json();
    const recs = data.recommendations || [];

    const container = document.getElementById("recommendationsListContainer");
    container.innerHTML = "";

    recs.forEach(r => {
      const card = document.createElement("div");
      card.className = "rec-card";
      card.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
          <div>
            <span class="rec-badge-high" style="background: ${r.priority.includes('High') ? 'var(--danger-bg)' : 'var(--primary-light)'}; color: ${r.priority.includes('High') ? 'var(--danger-text)' : 'var(--primary)'};">
              ${r.priority}
            </span>
            <h3 style="font-size: 1.2rem; margin-top: 0.5rem;">${r.learningPathTitle}</h3>
            <div style="font-size: 0.85rem; color: var(--text-muted);">
              <strong>Subject:</strong> ${r.targetSubject} • <strong>Topic:</strong> ${r.topicName}
            </div>
          </div>
          <div style="text-align: right; font-size: 0.85rem; font-weight: 700; color: var(--primary);">
            ⏱️ ~${r.estimatedHours} Hours Required
          </div>
        </div>

        <p style="font-size: 0.9rem; line-height: 1.5; color: var(--text-main);">
          ${r.actionPlan}
        </p>

        <div style="border-top: 1px solid var(--border-color); padding-top: 0.75rem; margin-top: 0.25rem;">
          <strong style="font-size: 0.8rem; color: var(--text-muted);">Recommended Learning Resources:</strong>
          <ul style="margin-left: 1.25rem; font-size: 0.85rem; color: var(--primary); margin-top: 0.35rem;">
            ${r.resourceLinks.map(link => `<li>${link}</li>`).join('')}
          </ul>
        </div>
      `;
      container.appendChild(card);
    });
  } catch (e) {
    console.error("Failed to load recommendations:", e);
  }
}

// --------------------------------------------------------------------------
// Slide 7: Student Report Document
// --------------------------------------------------------------------------
async function loadReportData(studentId = currentStudentId) {
  try {
    const res = await fetch(`/api/report?studentId=${studentId}`);
    const report = await res.json();

    document.getElementById("reportGeneratedDate").innerText = `Date: ${report.generatedDate}`;
    document.getElementById("reportIdBadge").innerText = report.reportId;
    document.getElementById("repStudentName").innerText = report.student.name;
    document.getElementById("repStudentRegNo").innerText = report.student.regNo;
    document.getElementById("repStudentDept").innerText = report.student.department;
    document.getElementById("repAvgScore").innerText = `${report.averageScore}%`;

    // 1. Course Performance Table
    const cpTbody = document.getElementById("repCoursePerfTableBody");
    cpTbody.innerHTML = "";
    report.coursePerformances.forEach(cp => {
      const tr = document.createElement("tr");
      const statusColor = cp.status === 'Strong' ? '#10b981' : (cp.status === 'Average' ? '#f59e0b' : '#ef4444');
      tr.innerHTML = `
        <td><strong>${cp.courseName}</strong></td>
        <td>${cp.score}%</td>
        <td>${cp.progress}%</td>
        <td><span style="font-weight: 700; color: ${statusColor};">${cp.status}</span></td>
      `;
      cpTbody.appendChild(tr);
    });

    // 2. Skill Analysis Table
    const saTbody = document.getElementById("repSkillAnalysisTableBody");
    saTbody.innerHTML = "";
    report.skillAnalytics.forEach(sa => {
      const tr = document.createElement("tr");
      const statusColor = sa.performance === 'Strong' ? '#10b981' : (sa.performance === 'Average' ? '#f59e0b' : '#ef4444');
      tr.innerHTML = `
        <td><strong>${sa.subject}</strong></td>
        <td>${sa.score}%</td>
        <td><span style="font-weight: 700; color: ${statusColor};">${sa.performance}</span></td>
      `;
      saTbody.appendChild(tr);
    });

    // 3. Recommendations
    const recList = document.getElementById("repRecommendationsList");
    recList.innerHTML = "";
    report.recommendations.forEach((r, idx) => {
      const div = document.createElement("div");
      div.style.marginBottom = "0.75rem";
      div.innerHTML = `
        <strong>${idx + 1}. ${r.targetSubject} (${r.topicName}) [${r.priority}]:</strong>
        <p style="margin-left: 1rem; color: #475569;">${r.actionPlan}</p>
      `;
      recList.appendChild(div);
    });
  } catch (e) {
    console.error("Failed to load report data:", e);
  }
}

function viewStudentReport(studentId) {
  currentStudentId = studentId;
  document.getElementById("studentSelector").value = studentId;
  switchTab('report');
  loadReportData(studentId);
}

// --------------------------------------------------------------------------
// Slide 8: Interactive UML & Database Diagram Explorer
// --------------------------------------------------------------------------
function showDiagram(type) {
  const canvas = document.getElementById("diagramCanvas");
  if (type === 'usecase') {
    canvas.innerHTML = `
      <h3 style="margin-bottom: 1rem;">Use Case Diagram (Slide 8)</h3>
      <div style="background: var(--bg-card-subtle); padding: 1.5rem; border-radius: var(--radius-md); font-family: monospace; font-size: 0.9rem; line-height: 1.8;">
        <strong>Actors:</strong> Student, Faculty / Admin<br><br>
        <strong>Use Cases:</strong><br>
        ├── 👤 [Student Login & Authentication]<br>
        ├── 📝 [Student Registration]<br>
        ├── 📖 [View Courses & Syllabi]<br>
        ├── ✍️ [Take Quizzes & Learning Activities]<br>
        ├── 📊 [Track Progress & Performance]<br>
        ├── 🚀 [View Personalized Recommendations]<br>
        └── 🖨️ [Generate & Print Student Reports]
      </div>
    `;
  } else if (type === 'class') {
    canvas.innerHTML = `
      <h3 style="margin-bottom: 1rem;">Class Diagram (Slide 8)</h3>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1rem;">
        <div style="border: 1px solid var(--border-color); border-radius: 8px; padding: 1rem; background: var(--bg-card-subtle);">
          <strong>Student</strong><hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          - id: int<br>- name: String<br>- email: String<br>- password: String<br>- department: String<br>- regNo: String<hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          + login()<br>+ register()<br>+ getProgress()
        </div>
        <div style="border: 1px solid var(--border-color); border-radius: 8px; padding: 1rem; background: var(--bg-card-subtle);">
          <strong>Course</strong><hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          - id: int<br>- code: String<br>- title: String<br>- category: String<br>- totalModules: int<hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          + getDetails()<br>+ getQuizzes()
        </div>
        <div style="border: 1px solid var(--border-color); border-radius: 8px; padding: 1rem; background: var(--bg-card-subtle);">
          <strong>SkillAnalytics</strong><hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          - subject: String<br>- score: double<br>- performance: String<br>- weakTopics: List<hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          + analyzeSkills()<br>+ identifyWeakness()
        </div>
        <div style="border: 1px solid var(--border-color); border-radius: 8px; padding: 1rem; background: var(--bg-card-subtle);">
          <strong>Recommendation</strong><hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          - targetSubject: String<br>- priority: String<br>- actionPlan: String<br>- estimatedHours: int<hr style="margin: 0.5rem 0; border: none; border-top: 1px solid var(--border-color);">
          + generatePath()
        </div>
      </div>
    `;
  } else if (type === 'sequence') {
    canvas.innerHTML = `
      <h3 style="margin-bottom: 1rem;">Sequence Diagram (Slide 8)</h3>
      <div style="background: var(--bg-card-subtle); padding: 1.5rem; border-radius: var(--radius-md); font-family: monospace; font-size: 0.88rem; line-height: 2;">
        1. Student ─── [Enter Credentials] ───► AuthController<br>
        2. AuthController ─── [Validate User] ───► DatabaseManager (JDBC)<br>
        3. DatabaseManager ─── [Return Student Entity] ───► AuthController<br>
        4. Client App ─── [Request Dashboard] ───► AnalyticsEngine<br>
        5. AnalyticsEngine ─── [Retrieve Progress Records] ───► ProgressDAO<br>
        6. AnalyticsEngine ─── [Analyze Skills & Weaknesses] ───► RecommendationEngine<br>
        7. RecommendationEngine ─── [Generate Adaptive Path] ───► ReportService<br>
        8. ReportService ─── [Display Dashboard & Printable Reports] ───► Student UI
      </div>
    `;
  } else if (type === 'er') {
    canvas.innerHTML = `
      <h3 style="margin-bottom: 1rem;">ER Diagram & Relational Schema (Slide 8 & 9)</h3>
      <div style="background: var(--bg-card-subtle); padding: 1.5rem; border-radius: var(--radius-md); font-family: monospace; font-size: 0.88rem; line-height: 2;">
        [STUDENTS] (1) ───────────&lt; (N) [STUDENT_PROGRESS] &gt;─────────── (1) [COURSES]<br>
        &nbsp;&nbsp;&nbsp;│<br>
        &nbsp;&nbsp;&nbsp;├─── (1) ───────────&lt; (N) [SKILL_ANALYTICS]<br>
        &nbsp;&nbsp;&nbsp;├─── (1) ───────────&lt; (N) [RECOMMENDATIONS]<br>
        &nbsp;&nbsp;&nbsp;└─── (1) ───────────&lt; (N) [REPORTS]<br><br>
        [COURSES] (1) ───────────&lt; (N) [QUIZ_QUESTIONS]
      </div>
    `;
  } else if (type === 'arch') {
    canvas.innerHTML = `
      <h3 style="margin-bottom: 1rem;">Updated System Architecture & Module Flow (Slide 3)</h3>
      <div style="background: var(--bg-card-subtle); padding: 1.5rem; border-radius: var(--radius-md); font-weight: 700; font-size: 0.95rem; line-height: 2.2; color: var(--primary);">
        Student ➔ Login ➔ Course Tracking ➔ Progress Analysis ➔ Skill Analytics ➔ Recommendation Engine ➔ Dashboard & Reports
      </div>
    `;
  }
}

// --------------------------------------------------------------------------
// Slide 12: Automated Test Suite Runner
// --------------------------------------------------------------------------
async function runBackendTests() {
  const tbody = document.getElementById("testResultsTableBody");
  tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; padding: 2rem;">⏳ Running Java Backend Test Suite...</td></tr>`;

  try {
    const res = await fetch("/api/tests/run");
    const data = await res.json();
    const tests = data.tests || [];

    tbody.innerHTML = "";
    tests.forEach(t => {
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td><span class="badge ${t.passed ? 'badge-strong' : 'badge-weak'}">${t.passed ? 'PASS' : 'FAIL'}</span></td>
        <td><strong>${t.category}</strong></td>
        <td>${t.testName}</td>
        <td style="color: var(--text-muted); font-size: 0.85rem;">${t.details}</td>
      `;
      tbody.appendChild(tr);
    });

    showToast("Automated Test Suite Completed Successfully!");
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="4" style="color: var(--danger); text-align: center;">Error running tests: ${e}</td></tr>`;
  }
}

// --------------------------------------------------------------------------
// Add Student & Login Handlers
// --------------------------------------------------------------------------
async function handleAddStudent(e) {
  e.preventDefault();
  const name = document.getElementById("newStudentName").value;
  const email = document.getElementById("newStudentEmail").value;
  const password = document.getElementById("newStudentPassword").value;
  const department = document.getElementById("newStudentDept").value;
  const regNo = document.getElementById("newStudentRegNo").value;

  try {
    const res = await fetch("/api/auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, email, password, department, regNo })
    });
    const result = await res.json();
    if (result.success) {
      showToast(`Student ${name} registered successfully!`);
      document.getElementById("addStudentForm").reset();
      await loadStudentsList();
      loadDashboardData();
    } else {
      alert("Registration failed: " + result.message);
    }
  } catch (err) {
    alert("Error: " + err);
  }
}

function openLoginModal() {
  document.getElementById("loginModal").classList.add("active");
}
function closeLoginModal() {
  document.getElementById("loginModal").classList.remove("active");
}

async function handleLoginSubmit(e) {
  e.preventDefault();
  const email = document.getElementById("loginEmail").value;
  const password = document.getElementById("loginPassword").value;

  try {
    const res = await fetch("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    const result = await res.json();
    if (result.success) {
      currentStudentId = result.student.id;
      document.getElementById("studentSelector").value = currentStudentId;
      showToast(`Welcome back, ${result.student.name}!`);
      closeLoginModal();
      loadDashboardData();
    } else {
      alert(result.message || "Invalid credentials.");
    }
  } catch (err) {
    alert("Login Error: " + err);
  }
}

async function fetchAll(urls) {
  const promises = urls.map(u => fetch(u).then(r => r.json()));
  return Promise.all(promises);
}

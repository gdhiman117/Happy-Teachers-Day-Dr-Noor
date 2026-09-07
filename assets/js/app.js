/**
 * TEACHER'S DAY VIDEO PORTAL — DR. MOHAMMAD FAISAL NOOR (LMTSM)
 * Student Video Wishes (Pallavi Chaudhary placed FIRST as requested)
 */

// ==========================================================================
// 1. STUDENT VIDEOS DATA (Pallavi Chaudhary placed FIRST)
// ==========================================================================
const studentVideos = [
  {
    id: 1,
    name: "Pallavi Chaudhary",
    section: "Section D",
    sectionKey: "d",
    duration: "0:55",
    src: "assets/videos/pallavi-chaudhary-section-d.mp4",
    badgeClass: "section-pill-d"
  },
  {
    id: 2,
    name: "Balreet Sharma",
    section: "Section C",
    sectionKey: "c",
    duration: "0:37",
    src: "assets/videos/balreet-sharma-section-c.mp4",
    badgeClass: "section-pill-c"
  },
  {
    id: 3,
    name: "Navjot Kaur",
    section: "Section D",
    sectionKey: "d",
    duration: "0:32",
    src: "assets/videos/navjot-kaur-section-d.mp4",
    badgeClass: "section-pill-d"
  },
  {
    id: 4,
    name: "Gunvir Singh",
    section: "Section D",
    sectionKey: "d",
    duration: "0:27",
    src: "assets/videos/gunvir-singh-section-d.mp4",
    badgeClass: "section-pill-d"
  },
  {
    id: 5,
    name: "Aneesha",
    section: "Section D",
    sectionKey: "d",
    duration: "0:18",
    src: "assets/videos/aneesha-section-d.mp4",
    badgeClass: "section-pill-d"
  }
];

let currentActiveIndex = 0;
let currentFilter = "all";

// ==========================================================================
// 2. RENDER VIDEO CARDS
// ==========================================================================
function renderVideoCards() {
  const grid = document.getElementById("video-cards-grid");
  if (!grid) return;

  const filteredVideos = studentVideos.filter(item => {
    return currentFilter === "all" || item.sectionKey === currentFilter;
  });

  grid.innerHTML = filteredVideos.map((video) => {
    const originalIndex = studentVideos.findIndex(v => v.id === video.id);

    return `
      <article class="video-card" onclick="openFullscreenReel(${originalIndex})">
        <div class="card-media-wrap">
          <video 
            class="card-video" 
            src="${video.src}" 
            preload="metadata" 
            muted 
            playsinline
          ></video>
          
          <div class="card-media-overlay">
            <div class="card-top-badges">
              <span class="section-tag-pill ${video.badgeClass}">${video.section}</span>
              <span class="duration-pill">
                <i class="fa-regular fa-clock"></i>
                ${video.duration}
              </span>
            </div>

            <div class="play-btn-circle" title="Play Fullscreen">
              <i class="fa-solid fa-play"></i>
            </div>
          </div>
        </div>

        <div class="card-student-info">
          <h3 class="student-name">${video.name}</h3>
          <p class="student-section-sub">${video.section} &bull; QTM &bull; LMTSM</p>
        </div>
      </article>
    `;
  }).join("");
}

// ==========================================================================
// 3. FULLSCREEN VIDEO PLAYER (DIRECT PLAYBACK, CLEAN MODAL)
// ==========================================================================
const modal = document.getElementById("fullscreen-video-modal");
const modalVideo = document.getElementById("modal-video");
const modalStudentName = document.getElementById("modal-student-name");
const modalStudentSec = document.getElementById("modal-student-sec");
const modalCounterBadge = document.getElementById("modal-counter-badge");

function openFullscreenReel(index = 0) {
  if (index < 0) index = 0;
  if (index >= studentVideos.length) index = studentVideos.length - 1;
  currentActiveIndex = index;

  loadVideoIntoModal(currentActiveIndex);

  if (modal) {
    modal.classList.add("active");
    document.body.style.overflow = "hidden";
  }

  // Request browser native fullscreen for maximum immersive viewing
  try {
    const el = document.documentElement;
    if (el.requestFullscreen) {
      el.requestFullscreen().catch(() => {});
    } else if (el.webkitRequestFullscreen) {
      el.webkitRequestFullscreen();
    }
  } catch (err) {}
}

function closeFullscreenReel() {
  if (modal) {
    modal.classList.remove("active");
    document.body.style.overflow = "";
  }
  if (modalVideo) {
    modalVideo.pause();
    modalVideo.src = "";
  }
  // Exit native fullscreen if open
  try {
    if (document.fullscreenElement && document.exitFullscreen) {
      document.exitFullscreen().catch(() => {});
    }
  } catch (e) {}
}

function loadVideoIntoModal(index) {
  const videoData = studentVideos[index];
  if (!videoData || !modalVideo) return;

  if (modalStudentName) modalStudentName.textContent = videoData.name;
  if (modalStudentSec) modalStudentSec.textContent = `${videoData.section} • Video ${index + 1} of ${studentVideos.length}`;
  if (modalCounterBadge) modalCounterBadge.textContent = `${index + 1} / ${studentVideos.length}`;

  modalVideo.src = videoData.src;
  modalVideo.currentTime = 0;
  modalVideo.load();

  const playPromise = modalVideo.play();
  if (playPromise !== undefined) {
    playPromise.catch(() => {
      // If browser blocks unmuted autoplay, unmute or click to play
      modalVideo.muted = false;
    });
  }
}

function nextVideo() {
  if (currentActiveIndex < studentVideos.length - 1) {
    currentActiveIndex++;
  } else {
    currentActiveIndex = 0; // Loop back to first
  }
  loadVideoIntoModal(currentActiveIndex);
}

function prevVideo() {
  if (currentActiveIndex > 0) {
    currentActiveIndex--;
  } else {
    currentActiveIndex = studentVideos.length - 1; // Loop to last
  }
  loadVideoIntoModal(currentActiveIndex);
}

function togglePlayPause() {
  if (!modalVideo) return;
  if (modalVideo.paused) {
    modalVideo.play();
  } else {
    modalVideo.pause();
  }
}

function toggleNativeFullscreen() {
  const container = modal;
  if (!document.fullscreenElement) {
    if (container.requestFullscreen) {
      container.requestFullscreen().catch(() => {});
    }
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen().catch(() => {});
    }
  }
}

// Auto advance when video ends
if (modalVideo) {
  modalVideo.addEventListener("ended", () => {
    nextVideo();
  });
}

// Keyboard navigation
window.addEventListener("keydown", (e) => {
  if (!modal || !modal.classList.contains("active")) return;
  
  if (e.key === "ArrowRight") {
    e.preventDefault();
    nextVideo();
  } else if (e.key === "ArrowLeft") {
    e.preventDefault();
    prevVideo();
  } else if (e.key === "Escape") {
    e.preventDefault();
    closeFullscreenReel();
  } else if (e.key === " ") {
    e.preventDefault();
    togglePlayPause();
  } else if (e.key === "f" || e.key === "F") {
    toggleNativeFullscreen();
  }
});

// ==========================================================================
// 4. INITIALIZE FILTERS & CARDS
// ==========================================================================
document.addEventListener("DOMContentLoaded", () => {
  renderVideoCards();

  // Filter Buttons
  document.querySelectorAll(".filter-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      currentFilter = btn.dataset.filter || "all";
      renderVideoCards();
    });
  });
});

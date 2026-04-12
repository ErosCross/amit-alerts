const alertContainer = document.getElementById('alert-container');
const menuWrapper = document.getElementById('menu-wrapper');
const closeBtn = document.getElementById('close-btn');
const saveSettingsBtn = document.getElementById('save-settings-btn');
const areaSelect = document.getElementById('selected-area');

const icons = {
    success: 'fas fa-check-circle',
    error: 'fas fa-exclamation-circle',
    warning: 'fas fa-exclamation-triangle',
    info: 'fas fa-info-circle'
};

window.addEventListener('message', function(event) {
    if (event.data.action === 'showAlert') {
        showAlert(event.data);
    } else if (event.data.action === 'openMenu') {
        populateAreas(event.data.areas, event.data.currentArea);
        menuWrapper.style.display = 'flex';
    }
});

function populateAreas(areas, currentArea) {
    // Clear dynamic options (keep the "all" option)
    areaSelect.querySelectorAll('option:not([value="all"])').forEach(opt => opt.remove());
    
    areas.forEach(area => {
        const option = document.createElement('option');
        option.value = area;
        option.textContent = area;
        if (area === currentArea) option.selected = true;
        areaSelect.appendChild(option);
    });
    
    if (currentArea === "all") {
        areaSelect.querySelector('option[value="all"]').selected = true;
    }
}

// Close Menu Function
function closeMenu() {
    menuWrapper.style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Close on button click
closeBtn.addEventListener('click', closeMenu);

// Close on Escape key
window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

// Save Settings
saveSettingsBtn.addEventListener('click', () => {
    const selectedArea = areaSelect.value;
    
    fetch(`https://${GetParentResourceName()}/saveSettings`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            area: selectedArea
        })
    });
    
    closeMenu();
    
    // Show a local success alert
    showAlert({
        type: 'success',
        title: 'הגדרות נשמרו',
        message: `מעתה תקבל התרעות עבור: ${selectedArea === "all" ? "כל הארץ" : selectedArea}`,
        duration: 3000
    });
});

function showAlert(data) {
    const wrapper = document.createElement('div');
    wrapper.className = `alert-wrapper type-${data.type}`;
    
    wrapper.innerHTML = `
        <div class="alert-item">
            <div class="alert-icon">
                <i class="${icons[data.type] || icons.info}"></i>
            </div>
            <div class="alert-content">
                <div class="alert-title">${data.title}</div>
                <div class="alert-message">${data.message}</div>
            </div>
            <div class="progress-bar"></div>
        </div>
    `;

    alertContainer.appendChild(wrapper);

    const progressBar = wrapper.querySelector('.progress-bar');
    progressBar.style.transition = `transform ${data.duration}ms linear`;
    
    // Start progress bar animation
    setTimeout(() => {
        progressBar.style.transform = 'scaleX(0)';
    }, 10);

    // Remove alert after duration
    setTimeout(() => {
        wrapper.classList.add('slide-out');
        setTimeout(() => {
            wrapper.remove();
        }, 500);
    }, data.duration);
}

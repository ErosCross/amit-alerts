const alertContainer = document.getElementById('alert-container');

const icons = {
    success: 'fas fa-check-circle',
    error: 'fas fa-exclamation-circle',
    warning: 'fas fa-exclamation-triangle',
    info: 'fas fa-info-circle'
};

window.addEventListener('message', function(event) {
    if (event.data.action === 'showAlert') {
        showAlert(event.data);
    }
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

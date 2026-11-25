/* ============================================================
   Win4Win — JavaScript
   ============================================================ */

/* ---------- Datos de los miembros del equipo ---------- */

const teamMembers = {
    edu: {
        name: 'Edu',
        role: 'Desarrollador',
        initial: 'E',
        description: 'Apasionado por el desarrollo web y la automatización de sistemas. Se encarga de la estructura del proyecto y la integración de las diferentes herramientas. Le gusta encontrar soluciones eficientes y mantener el código limpio.'
    },
    raul: {
        name: 'Raúl',
        role: 'Desarrollador',
        initial: 'R',
        description: 'Enfoque en scripting, administración de sistemas y buenas prácticas de desarrollo. Responsable de los scripts PowerShell y la automatización de la instalación. Detallista y orientado a la calidad.'
    },
    jose: {
        name: 'José',
        role: 'Desarrollador',
        initial: 'J',
        description: 'Interesado en la integración de herramientas y la experiencia de usuario. Se ocupa de la interfaz web y la usabilidad del proyecto. Busca que la herramienta sea intuitiva y accesible para todos.'
    }
};

/* ---------- Referencias al DOM ---------- */

const modal = document.getElementById('member-modal');
const modalName = document.getElementById('modal-name');
const modalAvatarLetter = document.getElementById('modal-avatar-letter');
const modalCloseBtn = document.querySelector('.modal-close');
const menuToggle = document.querySelector('.menu-toggle');
const mainNav = document.getElementById('main-nav');
const faqToggles = document.querySelectorAll('.faq-toggle');
const teamCards = document.querySelectorAll('.team-card');

/* ---------- Menú hamburguesa ---------- */

if (menuToggle && mainNav) {
    function setMenuOpen(isOpen) {
        mainNav.classList.toggle('is-open', isOpen);
        menuToggle.setAttribute('aria-expanded', String(isOpen));

        const menuLabel = menuToggle.querySelector('.sr-only');
        if (menuLabel) {
            menuLabel.textContent = isOpen ? 'Cerrar menú' : 'Abrir menú';
        }
    }

    menuToggle.addEventListener('click', () => {
        setMenuOpen(!mainNav.classList.contains('is-open'));
    });

    // Cerrar menú al hacer clic en un enlace
    mainNav.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            setMenuOpen(false);
        });
    });
}

/* ---------- FAQ acordeón ---------- */

faqToggles.forEach(toggle => {
    toggle.addEventListener('click', () => {
        const expanded = toggle.getAttribute('aria-expanded') === 'true';
        const answerId = toggle.getAttribute('aria-controls');
        const answer = document.getElementById(answerId);

        toggle.setAttribute('aria-expanded', String(!expanded));

        if (answer) {
            answer.hidden = expanded;
        }
    });
});

/* ---------- Modal de miembros ---------- */

let lastFocusedElement = null;

function setPageInert(isInert) {
    Array.from(document.body.children).forEach(element => {
        if (element !== modal) {
            element.inert = isInert;
        }
    });
}

function openModal(memberKey) {
    const member = teamMembers[memberKey];
    if (!member) return;

    lastFocusedElement = document.activeElement;

    // Rellenar el modal
    modalName.textContent = member.name;
    modal.querySelector('.modal-role').textContent = member.role;
    modal.querySelector('.modal-description').textContent = member.description;
    modalAvatarLetter.textContent = member.initial;

    // Mostrar modal
    setPageInert(true);
    modal.hidden = false;

    // Trap focus dentro del modal
    requestAnimationFrame(() => {
        modalCloseBtn.focus();
    });

    // Prevenir scroll del body
    document.body.style.overflow = 'hidden';
}

function closeModal() {
    modal.hidden = true;
    setPageInert(false);
    document.body.style.overflow = '';

    // Restaurar foco
    if (lastFocusedElement) {
        lastFocusedElement.focus();
    }
}

// Abrir modal desde las tarjetas
teamCards.forEach(card => {
    const memberKey = card.dataset.member;

    card.addEventListener('click', () => {
        openModal(memberKey);
    });

    card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            openModal(memberKey);
        }
    });
});

// Cerrar modal
if (modalCloseBtn) {
    modalCloseBtn.addEventListener('click', closeModal);
}

// Cerrar al hacer clic fuera del contenido
if (modal) {
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeModal();
        }
    });
}

// Cerrar con Escape y trap focus
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !modal.hidden) {
        closeModal();
        return;
    }

    // Trap focus dentro del modal
    if (!modal.hidden && e.key === 'Tab') {
        const focusableElements = modal.querySelectorAll(
            'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        const firstElement = focusableElements[0];
        const lastElement = focusableElements[focusableElements.length - 1];

        if (e.shiftKey) {
            if (document.activeElement === firstElement) {
                e.preventDefault();
                lastElement.focus();
            }
        } else {
            if (document.activeElement === lastElement) {
                e.preventDefault();
                firstElement.focus();
            }
        }
    }
});

/* ---------- Smooth scroll para enlaces internos ---------- */

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
        const targetId = anchor.getAttribute('href');
        if (targetId === '#') return;

        const target = document.querySelector(targetId);
        if (target) {
            e.preventDefault();
            target.scrollIntoView({ behavior: 'smooth' });

            // Dar foco al destino para accesibilidad
            target.setAttribute('tabindex', '-1');
            target.focus({ preventScroll: true });
        }
    });
});

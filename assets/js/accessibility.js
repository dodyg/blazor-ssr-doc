document.addEventListener('DOMContentLoaded', () => {
    const status = document.createElement('div');
    status.className = 'visually-hidden';
    status.setAttribute('aria-live', 'polite');
    status.setAttribute('aria-atomic', 'true');
    document.body.appendChild(status);

    document.querySelectorAll('.nav-item.active a, .menu-item.active a').forEach((link) => {
        link.setAttribute('aria-current', 'page');
    });

    const enhanceCopyButton = (button) => {
        if (button.dataset.accessibilityReady === 'true') return;
        button.dataset.accessibilityReady = 'true';
        const copyLabel = button.getAttribute('data-bs-title') || 'Copy code to clipboard';
        button.setAttribute('aria-label', copyLabel);
        button.querySelectorAll('span').forEach((icon) => icon.setAttribute('aria-hidden', 'true'));

        new MutationObserver(() => {
            const state = button.getAttribute('data-copy-state');
            const message = state === 'copy-success'
                ? 'Code copied to clipboard'
                : state === 'copy-error'
                    ? 'Unable to copy code'
                    : copyLabel;
            button.setAttribute('aria-label', message);
            if (state === 'copy-success' || state === 'copy-error') status.textContent = message;
        }).observe(button, { attributes: true, attributeFilter: ['data-copy-state'] });
    };

    const enhanceMenuToggle = (toggle) => {
        if (toggle.hasAttribute('aria-label')) return;
        const sectionName = toggle.parentElement?.querySelector('.menu-link:not(.menu-link-show)')?.textContent?.trim() || 'navigation';
        toggle.setAttribute('aria-label', `Toggle ${sectionName} section`);
    };

    document.querySelectorAll('button.copy-to-clipboard-button').forEach(enhanceCopyButton);
    document.querySelectorAll('.menu-link-show').forEach(enhanceMenuToggle);
    new MutationObserver((mutations) => {
        mutations.forEach((mutation) => mutation.addedNodes.forEach((node) => {
            if (!(node instanceof Element)) return;
            if (node.matches('button.copy-to-clipboard-button')) enhanceCopyButton(node);
            node.querySelectorAll?.('button.copy-to-clipboard-button').forEach(enhanceCopyButton);
            if (node.matches('.menu-link-show')) enhanceMenuToggle(node);
            node.querySelectorAll?.('.menu-link-show').forEach(enhanceMenuToggle);
        }));
    }).observe(document.body, { childList: true, subtree: true });

    document.querySelectorAll('.js-toc-content table').forEach((table, index) => {
        if (table.parentElement?.classList.contains('table-scroll')) return;
        const wrapper = document.createElement('div');
        wrapper.className = 'table-scroll';
        wrapper.setAttribute('role', 'region');
        wrapper.setAttribute('tabindex', '0');
        const heading = table.previousElementSibling?.closest('h2, h3, h4') ||
            [...document.querySelectorAll('h2, h3, h4')].filter((item) => item.compareDocumentPosition(table) & Node.DOCUMENT_POSITION_FOLLOWING).pop();
        wrapper.setAttribute('aria-label', `${heading?.textContent?.trim() || `Data table ${index + 1}`} — scroll horizontally for more columns`);
        table.parentNode.insertBefore(wrapper, table);
        wrapper.appendChild(table);
    });

    document.querySelectorAll('.js-toc-content pre').forEach((pre) => {
        pre.setAttribute('tabindex', '0');
        const languageClass = [...(pre.querySelector('code')?.classList || [])].find((name) => name.startsWith('language-'));
        pre.setAttribute('aria-label', `${languageClass ? languageClass.slice(9) : 'Code'} example`);
    });
});

/**
 * お問い合わせフォーム処理
 */

(function() {
    'use strict';

    const form = document.getElementById('contact-form');
    const successMessage = document.getElementById('success-message');
    const errorMessage = document.getElementById('error-message');
    const errorDetail = document.getElementById('error-detail');

    /**
     * HTMLエスケープ
     */
    function escapeHtml(text) {
        if (text === null || text === undefined) return '';
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return String(text).replace(/[&<>"']/g, m => map[m]);
    }

    /**
     * フォーム送信処理
     */
    form.addEventListener('submit', async function(e) {
        e.preventDefault();

        // エラーメッセージをクリア
        clearErrors();
        successMessage.style.display = 'none';
        errorMessage.style.display = 'none';

        // フォームデータを取得
        const formData = {
            name: document.getElementById('name').value.trim(),
            email: document.getElementById('email').value.trim(),
            subject: document.getElementById('subject').value.trim(),
            message: document.getElementById('message').value.trim()
        };

        try {
            // ボタンを無効化
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.textContent = '送信中...';

            // APIに送信
            const response = await fetch('api/contact_submit.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });

            const result = await response.json();

            if (result.success) {
                // 成功メッセージを表示
                successMessage.style.display = 'block';
                form.style.display = 'none';

                // スクロール
                window.scrollTo(0, 0);
            } else {
                // エラー処理
                if (result.errors && typeof result.errors === 'object') {
                    // バリデーションエラー
                    displayFieldErrors(result.errors);
                    errorDetail.innerHTML = '入力内容をご確認ください。';
                } else {
                    // その他のエラー
                    errorDetail.innerHTML = escapeHtml(result.message || 'エラーが発生しました');
                }
                errorMessage.style.display = 'block';

                // ボタンを戻す
                submitBtn.disabled = false;
                submitBtn.textContent = '送信';

                // スクロール
                window.scrollTo(0, errorMessage.offsetTop - 100);
            }

        } catch (error) {
            console.error('Error:', error);
            errorDetail.innerHTML = 'ネットワークエラーが発生しました。接続をご確認ください。';
            errorMessage.style.display = 'block';

            // ボタンを戻す
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.disabled = false;
            submitBtn.textContent = '送信';
        }
    });

    /**
     * フィールドのエラーメッセージを表示
     */
    function displayFieldErrors(errors) {
        for (const [field, message] of Object.entries(errors)) {
            const errorElement = document.getElementById(`${field}-error`);
            if (errorElement) {
                errorElement.textContent = escapeHtml(message);
                errorElement.style.display = 'block';
            }
        }
    }

    /**
     * エラーメッセージをクリア
     */
    function clearErrors() {
        document.querySelectorAll('.error-message').forEach(el => {
            el.textContent = '';
            el.style.display = 'none';
        });
    }

    /**
     * フォームをリセット
     */
    window.resetForm = function() {
        form.reset();
        clearErrors();
        errorMessage.style.display = 'none';
        form.style.display = 'block';
        window.scrollTo(0, 0);
    };

})();

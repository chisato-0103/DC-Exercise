/**
 * 愛知工業大学 交通情報システム
 * クライアントサイドスクリプト
 */

(function() {
    'use strict';

    /**
     * 現在時刻を更新する関数
     */
    function updateCurrentTime() {
        const currentTimeElement = document.querySelector('.current-time');
        if (!currentTimeElement) return;

        const now = new Date();
        const year = now.getFullYear();
        const month = now.getMonth() + 1;
        const day = now.getDate();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');

        const formattedTime = `現在時刻: ${year}年${month}月${day}日 ${hours}:${minutes}:${seconds}`;
        currentTimeElement.textContent = formattedTime;
    }

    /**
     * カウントダウン表示を更新
     */
    function updateCountdown() {
        const countdownElement = document.getElementById('countdown');
        if (!countdownElement) return;

        const departureTime = countdownElement.getAttribute('data-departure');
        if (!departureTime) return;

        const now = new Date();
        const [hours, minutes] = departureTime.split(':').map(Number);

        const departure = new Date();
        departure.setHours(hours, minutes, 0, 0);

        // 翌日の場合の処理
        if (departure < now) {
            departure.setDate(departure.getDate() + 1);
        }

        const diff = Math.floor((departure - now) / 1000); // 秒単位
        const minutesLeft = Math.floor(diff / 60);
        const secondsLeft = diff % 60;

        if (minutesLeft < 0) {
            countdownElement.textContent = '出発しました';
            return;
        }

        countdownElement.textContent = `あと ${minutesLeft}分${secondsLeft}秒`;

        // 5分以内なら緊急表示
        if (minutesLeft < 5) {
            countdownElement.classList.add('urgent');
        } else {
            countdownElement.classList.remove('urgent');
        }
    }

    /**
     * 折りたたみ機能をセットアップ
     */
    function setupCollapsibles() {
        const collapsibles = document.querySelectorAll('.collapsible');

        collapsibles.forEach(function(collapsible) {
            const header = collapsible.querySelector('.collapsible-header');
            if (!header) return;

            header.addEventListener('click', function() {
                collapsible.classList.toggle('active');
            });
        });
    }

    /**
     * ページを自動リロードする関数（1分ごと）
     */
    function setupAutoReload() {
        // 1分ごとにページをリロード
        setInterval(function() {
            location.reload();
        }, 60000); // 60秒 = 1分
    }

    /**
     * 初期化処理
     */
    function init() {
        // 現在時刻を1秒ごとに更新
        updateCurrentTime();
        setInterval(updateCurrentTime, 1000);

        // カウントダウンを1秒ごとに更新
        updateCountdown();
        setInterval(updateCountdown, 1000);

        // 折りたたみ機能をセットアップ
        setupCollapsibles();

        // 1分ごとに自動リロード
        setupAutoReload();

        console.log('愛工大交通情報システム: 初期化完了');
    }

    // DOMContentLoadedイベントで初期化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();

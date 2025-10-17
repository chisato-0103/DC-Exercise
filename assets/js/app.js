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

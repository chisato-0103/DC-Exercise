/**
 * 愛知工業大学 交通情報システム
 * トップページ（index.html）用スクリプト
 */

(function () {
    'use strict';

    let stations = [];
    let currentDirection = 'to_station';
    let currentDestination = 'fujigaoka';
    let currentOrigin = 'fujigaoka';

    /**
     * URLパラメータを取得
     */
    function getURLParams() {
        const params = new URLSearchParams(window.location.search);
        const direction = params.get('direction') || 'to_station';

        return {
            direction: direction,
            destination: params.get('destination') || 'fujigaoka',
            origin: params.get('origin') || 'fujigaoka'
        };
    }

    /**
     * お知らせを表示
     */
    async function loadNotices() {
        try {
            const notices = await API.getNotices('all');

            if (notices.length === 0) {
                document.querySelector('.notices').style.display = 'none';
                return;
            }

            const noticesContainer = document.querySelector('.notices .collapsible-content');
            noticesContainer.innerHTML = notices.map(notice => `
                <div class="notice-item ${notice.notice_type === 'suspension' ? 'danger' : (notice.notice_type === 'delay' ? 'warning' : '')}">
                    <div class="notice-title">${escapeHtml(notice.title)}</div>
                    <div class="notice-content">${escapeHtml(notice.content)}</div>
                </div>
            `).join('');

        } catch (error) {
            console.error('Failed to load notices:', error);
        }
    }

    /**
     * 駅リストを読み込んでセレクトボックスに設定
     */
    async function loadStations() {
        try {
            stations = await API.getStations();

            const destinationSelect = document.getElementById('destination');
            const originSelect = document.getElementById('origin');

            // 目的地：リニモ駅 + 八草駅
            const destinationOptions = stations
                .map(station => `
                    <option value="${escapeHtml(station.station_code)}">
                        ${escapeHtml(station.station_name)}
                    </option>
                `).join('');

            // 出発地：リニモ駅 + 八草駅
            const originOptions = `
                <option value="yagusa">八草駅</option>
                ${stations
                    .filter(station => station.station_code !== 'yagusa')
                    .map(station => `
                        <option value="${escapeHtml(station.station_code)}">
                            ${escapeHtml(station.station_name)}
                        </option>
                    `).join('')}
            `;

            if (destinationSelect) destinationSelect.innerHTML = destinationOptions;
            if (originSelect) originSelect.innerHTML = originOptions;

        } catch (error) {
            console.error('Failed to load stations:', error);
        }
    }

    /**
     * 次の便を表示
     */
    async function loadNextConnection() {
        const params = getURLParams();
        currentDirection = params.direction;
        currentDestination = params.destination;
        currentOrigin = params.origin;

        try {
            const data = await API.getNextConnection(
                currentDirection,
                currentDirection === 'to_station' ? currentDestination : null,
                currentDirection === 'to_university' ? currentOrigin : null
            );

            // 現在時刻とダイヤ情報を更新
            updateCurrentTimeDisplay(data);

            // フォーム値を復元
            document.getElementById('direction').value = currentDirection;
            // 方向に応じて目的地/出発地の表示を切り替え
            toggleDirectionFields(currentDirection);
            if (currentDirection === 'to_station') {
                document.getElementById('destination').value = currentDestination;
            } else if (currentDirection === 'to_university') {
                document.getElementById('origin').value = currentOrigin;
            }

            // ルート表示
            renderRoutes(data);

        } catch (error) {
            console.error('Failed to load next connection:', error);
            showError('接続情報の取得に失敗しました。');
        }
    }

    /**
     * 現在時刻とダイヤ情報を更新
     */
    function updateCurrentTimeDisplay(data) {
    const currentTimeElement = document.querySelector('.current-time');
    if (!currentTimeElement || !data.data) return;

    // 現在時刻のみ取得（HH:MM:SS形式）
    const { current_time } = data.data;

    currentTimeElement.textContent = escapeHtml(current_time);
}


    /**
     * ルート情報をレンダリング
     */
    function renderRoutes(apiResponse) {
        if (!apiResponse.data) {
            showError('データの取得に失敗しました。');
            return;
        }

        const { routes, from_name, to_name, service_info } = apiResponse.data;

        // 次の便（最初のルート）
        if (routes && routes.length > 0) {
            renderNextDeparture(routes[0], currentDirection);
            renderOtherRoutes(routes.slice(1), currentDirection);
        } else {
            renderNoService(service_info);
        }
    }

    /**
     * 時刻文字列から秒数を削除（HH:MM:SS → HH:MM）
     */
    function formatTimeWithoutSeconds(timeStr) {
        if (!timeStr) return '';
        // HH:MM:SS形式の場合は秒数を削除、すでにHH:MM形式の場合はそのまま返す
        if (timeStr.length > 5) {
            return timeStr.substring(0, 5);
        }
        return timeStr;
    }

    /**
     * 次の便を表示
     */
    function renderNextDeparture(route, direction) {
        const container = document.querySelector('.next-departure');
        let departureTime = '';
        let title = '';
        let routeInfo = '';

        if (direction === 'to_station') {
            departureTime = formatTimeWithoutSeconds(route.shuttle_departure);
            title = '次に乗るシャトルバス';
            // 八草駅が目的地の場合はシャトルバスのみ表示
            if (route.destination_name === '八草') {
                routeInfo = `<img src="assets/image/school-flag-svgrepo-com 2.svg" /> 愛知工業大学 → <img src="assets/image/bus-svgrepo-com 2.svg" /> 八草駅`;
            } else {
                routeInfo = `<img src="assets/image/school-flag-svgrepo-com 2.svg" /> 愛知工業大学 → <img src="assets/image/bus-svgrepo-com 2.svg" /> 八草駅 → <img src="assets/image/train-svgrepo-com 2.svg" /> ${escapeHtml(route.destination_name)}`;
            }
        } else if (direction === 'to_university') {
            if (route.origin_name === '八草駅') {
                // 八草駅 → 大学の場合、シャトルバスの出発時刻を表示
                departureTime = formatTimeWithoutSeconds(route.shuttle_departure);
                title = '次に乗るシャトルバス';
                routeInfo = `<img src="assets/image/bus-svgrepo-com 2.svg" /> 八草駅 → <img src="assets/image/school-flag-svgrepo-com 2.svg" /> 愛知工業大学`;
            } else {
                // リニモ駅 → 大学の場合、リニモの出発時刻を表示
                departureTime = formatTimeWithoutSeconds(route.linimo_departure);
                title = '次に乗るリニモ';
                routeInfo = `<img src="assets/image/train-svgrepo-com 2.svg" /> ${escapeHtml(route.origin_name)} → <img src="assets/image/bus-svgrepo-com 2.svg" /> 八草駅 → <img src="assets/image/school-flag-svgrepo-com 2.svg" /> 愛知工業大学`;
            }
        }

        container.innerHTML = `
            <div class="next-departure-title">${title}</div>
            <div class="next-departure-time">${escapeHtml(departureTime)} 発</div>
            <div class="next-departure-info">
                ${routeInfo}
            </div>
            <div style="text-align: center;">
                <span class="countdown" id="countdown" data-departure="${escapeHtml(departureTime)}">
                    あと ${escapeHtml(route.waiting_time)} 分
                </span>
            </div>
            <div style="text-align: center; margin-top: 0.5rem; opacity: 0.9; font-size: 0.9rem;">
                タップで詳細を表示 ▼
            </div>
            <div class="next-departure-details">
                ${renderRouteDetails(route, direction)}
            </div>
        `;

        container.style.display = 'block';
        container.onclick = function () {
            this.classList.toggle('expanded');
        };
    }

    /**
     * ルート詳細を生成
     */
    function renderRouteDetails(route, direction) {
        let html = '<div style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid rgba(255,255,255,0.3);"><div class="route-steps" style="color: white;">';

        if (direction === 'to_station') {
            // 八草駅が目的地の場合（シャトルバスのみ）
            if (route.destination_name === '八草') {
                html += `
                    <div class="route-step">
                        <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                `;
            } else {
                // リニモ駅が目的地の場合（シャトルバス + リニモ）
                html += `
                    <div class="route-step">
                        <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">シャトルバス約5分</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/time-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                            <div class="route-step-detail">リニモへ乗り換え</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/train-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_departure))}</div>
                            <div class="route-step-detail">リニモで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/flag-2-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds(route.destination_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                `;
            }
        } else {
            // リニモ駅 → 大学 または 八草駅 → 大学
            if (route.origin_name === '八草駅') {
                // 八草駅 → 大学
                html += `
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                `;
            } else {
                // リニモ駅 → 大学
                html += `
                    <div class="route-step">
                        <img src="assets/image/train-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">${escapeHtml(route.origin_name)} 発 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_departure))}</div>
                            <div class="route-step-detail">リニモで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 着 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_arrival))}</div>
                            <div class="route-step-detail">リニモ約${escapeHtml(route.linimo_time)}分</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/time-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                            <div class="route-step-detail">シャトルバスへ乗り換え</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                `;
            }
        }

        html += `</div>
            <div class="route-summary" style="background-color: rgba(255,255,255,0.1); border-top-color: rgba(255,255,255,0.3);">
                <div class="summary-item">
                    <span class="summary-label">待ち時間</span>
                    <span class="summary-value" style="color: white;">${escapeHtml(route.waiting_time)}分</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">乗り換え</span>
                    <span class="summary-value" style="color: white;">${escapeHtml(route.transfer_time)}分</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">総所要時間</span>
                    <span class="summary-value" style="color: white;">${escapeHtml(route.total_time)}分</span>
                </div>
            </div></div>`;

        return html;
    }

    /**
     * 他のルートを表示
     */
    function renderOtherRoutes(routes, direction) {
        const container = document.querySelector('.results');

        if (!routes || routes.length === 0) {
            container.style.display = 'none';
            return;
        }

        let html = '<h3 style="margin-bottom: 1rem; color: var(--primary-color);">他の候補</h3>';

        routes.forEach((route, index) => {
            let departureTime = '';
            let departureIcon = '';

            if (direction === 'to_station') {
                departureTime = formatTimeWithoutSeconds(route.shuttle_departure);
                departureIcon = '<img src="assets/image/school-flag-svgrepo-com.svg" />';
            } else if (direction === 'to_university') {
                if (route.origin_name === '八草駅') {
                    departureTime = formatTimeWithoutSeconds(route.shuttle_departure);
                    departureIcon = '<img src="assets/image/bus-svgrepo-com.svg" />';
                } else {
                    departureTime = formatTimeWithoutSeconds(route.linimo_departure);
                    departureIcon = '<img src="assets/image/train-svgrepo-com.svg" />';
                }
            }

            html += `
                <div class="route-card-compact" onclick="this.classList.toggle('expanded')">
                    <div class="route-header">
                        <span class="route-number">ルート ${index + 2}</span>
                        <span class="route-total-time">${escapeHtml(route.total_time)}分</span>
                    </div>
                    <div class="route-quick-info">
                        <span class="route-quick-time">
                            ${departureIcon} ${escapeHtml(departureTime)} 発
                        </span>
                        <span class="expand-icon">▼</span>
                    </div>
                    <div class="route-steps">
                        ${renderCompactRouteSteps(route, direction)}
                    </div>
                </div>
            `;
        });

        container.innerHTML = html;
        container.style.display = 'block';
    }

    /**
     * コンパクトルート詳細を生成
     */
    function renderCompactRouteSteps(route, direction) {
        let html = '';

        if (direction === 'to_station') {
            html = `

                <div class="route-step">
                <img src="assets/image/school-flag-svgrepo-com.svg" />
                    <div class="route-step-content">
                    <div class="route-step-time">愛知工業大学 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                    <div class="route-step-detail">シャトルバスで出発</div>
                    </div>
                </div>

                <div class="route-arrow">↓</div>
                <div class="route-step">
                <img src="assets/image/bus-svgrepo-com.svg" />
                    <div class="route-step-content">
                        <div class="route-step-time">八草駅 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                        <div class="route-step-detail">シャトルバス約5分</div>
                    </div>
                </div>

                <div class="route-arrow">↓</div>
                <div class="route-step">
                <img src="assets/image/time-svgrepo-com.svg" />
                    <div class="route-step-content">
                        <div class="route-step-time">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                        <div class="route-step-detail">リニモへ乗り換え</div>
                    </div>
                </div>
                <div class="route-arrow">↓</div>
                <div class="route-step">
                    <img src="assets/image/train-svgrepo-com.svg" />
                    <div class="route-step-content">
                        <div class="route-step-time">八草駅 発 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_departure))}</div>
                        <div class="route-step-detail">リニモで出発</div>
                    </div>
                </div>
                <div class="route-arrow">↓</div>
                <div class="route-step">
                    <img src="assets/image/flag-2-svgrepo-com.svg" />
                    <div class="route-step-content">
                        <div class="route-step-time">${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds(route.destination_arrival))}</div>
                        <div class="route-step-detail">到着</div>
                    </div>
                </div>
            `;
        } else {
            // リニモ駅 → 大学 または 八草駅 → 大学
            if (route.origin_name === '八草駅') {
                // 八草駅 → 大学
                html = `
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step">
                        <img src="assets/image/flag-2-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                `;
            } else {
                // リニモ駅 → 大学
                html = `
                    <div class="route-step">
                        <img src="assets/image/train-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">${escapeHtml(route.origin_name)} 発 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_departure))}</div>
                            <div class="route-step-detail">リニモで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step">
                        <img src="assets/image/train-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 着 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_arrival))}</div>
                            <div class="route-step-detail">リニモ約${escapeHtml(route.linimo_time)}分</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step">
                        <img src="assets/image/time-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                            <div class="route-step-detail">シャトルバスへ乗り換え</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step">
                        <img src="assets/image/bus-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_departure))}</div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step">
                        <img src="assets/image/flag-2-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                `;
            }
        }

        html += `
            <div class="route-summary">
                <div class="summary-item">
                    <span class="summary-label">待ち時間</span>
                    <span class="summary-value">${escapeHtml(route.waiting_time)}分</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">乗り換え</span>
                    <span class="summary-value">${escapeHtml(route.transfer_time)}分</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">総所要時間</span>
                    <span class="summary-value">${escapeHtml(route.total_time)}分</span>
                </div>
            </div>
        `;

        return html;
    }

    /**
     * 運行なしの場合の表示
     */
    function renderNoService(serviceInfo) {
        const container = document.querySelector('.next-departure');

        if (!serviceInfo) {
            container.innerHTML = `
                <div class="error-message">
                    <strong>お知らせ</strong>
                    <p>現在、表示可能な乗り継ぎルートがありません。運行時間をご確認ください。</p>
                </div>
            `;
            return;
        }

        let html = '<div class="error-message">';

        if (serviceInfo.is_before_service) {
            html += `
                <strong>⏰ 運行開始前</strong>
                <p>本日の運行はまだ開始していません。</p>
            `;
            if (serviceInfo.first) {
                html += `
                    <p style="font-size: 1.1em; margin-top: 8px;">
                        初便: <strong>${escapeHtml(serviceInfo.first)} 発</strong>（${escapeHtml(serviceInfo.direction_text)}）
                    </p>
                `;
            }
        } else if (serviceInfo.is_after_service) {
            html += `<strong>🌙 本日の運行は終了しました</strong>`;
            if (serviceInfo.last) {
                html += `<p>最終便: ${escapeHtml(serviceInfo.last)} 発（${escapeHtml(serviceInfo.direction_text)}）</p>`;
            }
            if (serviceInfo.first) {
                html += `
                    <p style="margin-top: 12px; padding-top: 12px; border-top: 1px solid rgba(255,255,255,0.2);">
                        明日の初便: <strong>${escapeHtml(serviceInfo.first)} 発</strong>（${escapeHtml(serviceInfo.direction_text)}）
                    </p>
                `;
            }
        } else {
            html += `
                <strong>お知らせ</strong>
                <p>現在、表示可能な乗り継ぎルートがありません。</p>
            `;
            if (serviceInfo.last) {
                html += `
                    <p style="font-size: 0.9em; margin-top: 8px;">
                        最終便: ${escapeHtml(serviceInfo.last)} 発（${escapeHtml(serviceInfo.direction_text)}）
                    </p>
                `;
            }
        }

        html += '</div>';
        container.innerHTML = html;
    }

    /**
     * エラーメッセージを表示
     */
    function showError(message) {
        const container = document.querySelector('.next-departure');
        container.innerHTML = `
            <div class="error-message">
                <strong>エラー</strong>
                <p>${escapeHtml(message)}</p>
            </div>
        `;
    }

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
     * 方向切り替えイベント
     */
    function toggleDirectionFields(direction) {
        const destinationGroup = document.getElementById('destination-group');
        const originGroup = document.getElementById('origin-group');

        if (direction === 'to_station') {
            destinationGroup.style.display = '';
            originGroup.style.display = 'none';
        } else {
            destinationGroup.style.display = 'none';
            originGroup.style.display = '';
        }
    }

    /**
     * 初期化
     */
    async function init() {
        await loadStations();
        await loadNotices();
        await loadNextConnection();

        // 方向切り替えイベント
        const directionSelect = document.getElementById('direction');
        if (directionSelect) {
            directionSelect.addEventListener('change', function () {
                toggleDirectionFields(this.value);
            });
            toggleDirectionFields(directionSelect.value);
        }
    }

    // DOMContentLoadedイベントで初期化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // グローバルに公開（HTMLから呼び出せるように）
    window.toggleDirectionFields = toggleDirectionFields;
})();

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
            noticesContainer.innerHTML = notices.map(notice => {
                // 日付をフォーマット（YYYY-MM-DD）
                const startDate = notice.start_date ? notice.start_date.split(' ')[0] : '';
                return `
                <div class="notice-item ${notice.notice_type === 'suspension' ? 'danger' : (notice.notice_type === 'delay' ? 'warning' : '')}">
                    <div class="notice-title">${escapeHtml(notice.title)}</div>
                    ${startDate ? `<div class="notice-date">${escapeHtml(startDate)}</div>` : ''}
                    <div class="notice-content">${escapeHtml(notice.content)}</div>
                </div>
            `;
            }).join('');

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

        const { routes, from_name, to_name, service_info, dia_description } = apiResponse.data;

        // 次の便（最初のルート）
        if (routes && routes.length > 0) {
            renderNextDeparture(routes[0], currentDirection);
            renderOtherRoutes(routes.slice(1), currentDirection);
        } else {
            renderNoService(service_info, dia_description);
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
        container.onclick = function (e) {
            // ラジオボタンやスパンをクリックした場合は詳細の開閉をしない
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'SPAN') {
                return;
            }
            this.classList.toggle('expanded');
        };

        // リニモ選択ラジオボタンにイベントリスナーを追加
        setTimeout(() => {
            const radioButtons = container.querySelectorAll('input[type="radio"][data-route]');
            const linimoSegmentLabels = container.querySelectorAll('.linimo-segment-label');
            const linimoSegmentButtons = container.querySelectorAll('.linimo-segment-button');

            radioButtons.forEach((radio) => {
                radio.addEventListener('change', function (e) {
                    e.stopPropagation();
                    e.preventDefault();
                    const route = JSON.parse(this.getAttribute('data-route'));
                    const selectedIndex = parseInt(this.getAttribute('data-index'));
                    updateLinimoChoice(this, route, selectedIndex);
                    return false;
                }, true); // キャプチャフェーズでリッスン
            });

            // セグメントボタンがクリックされたときはラジオボタンを選択
            linimoSegmentButtons.forEach((button) => {
                button.addEventListener('click', function (e) {
                    e.stopPropagation();
                    const label = this.closest('.linimo-segment-label');
                    if (label) {
                        const radio = label.querySelector('input[type="radio"]');
                        if (radio && !radio.checked) {
                            radio.checked = true;
                            radio.dispatchEvent(new Event('change', { bubbles: true }));
                        }
                    }
                });
            });

            // ラベル全体でもクリック可能に
            linimoSegmentLabels.forEach((label) => {
                label.addEventListener('click', function (e) {
                    e.stopPropagation();
                });
            });

            // シャトルバス選択ウィジェット用のイベントリスナーを追加
            const shuttleRadioButtons = container.querySelectorAll('input[type="radio"][name^="shuttle_option_"]');
            const shuttleSegmentLabels = container.querySelectorAll('.shuttle-segment-label');
            const shuttleSegmentButtons = container.querySelectorAll('.shuttle-segment-button');

            shuttleRadioButtons.forEach((radio) => {
                radio.addEventListener('change', function (e) {
                    e.stopPropagation();
                    e.preventDefault();
                    const route = JSON.parse(this.getAttribute('data-route'));
                    const selectedIndex = parseInt(this.getAttribute('data-index'));
                    updateShuttleChoice(this, route, selectedIndex);
                    return false;
                }, true);
            });

            shuttleSegmentButtons.forEach((button) => {
                button.addEventListener('click', function (e) {
                    e.stopPropagation();
                    const label = this.closest('.shuttle-segment-label');
                    if (label) {
                        const radio = label.querySelector('input[type="radio"]');
                        if (radio && !radio.checked) {
                            radio.checked = true;
                            radio.dispatchEvent(new Event('change', { bubbles: true }));
                        }
                    }
                });
            });

            shuttleSegmentLabels.forEach((label) => {
                label.addEventListener('click', function (e) {
                    e.stopPropagation();
                });
            });

            // スマホ時は縦並びに（幅が600px以下の場合）
            if (window.innerWidth <= 600) {
                linimoSegmentLabels.forEach((label) => {
                    label.style.flex = '1 1 100%';
                    label.style.minWidth = 'unset';
                });
                shuttleSegmentLabels.forEach((label) => {
                    label.style.flex = '1 1 100%';
                    label.style.minWidth = 'unset';
                });
            }
        }, 0);
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
                `;

                // リニモ選択ウィジェット（セグメンテッドコントロール風）
                if (route.linimo_options && route.linimo_options.length > 0) {
                    html += `
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step transfer-time-step" data-shuttle-departure="${route.shuttle_departure.replace(/:/g, '-')}">
                            <img src="assets/image/time-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time transfer-time-display">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                                <div class="route-step-detail">リニモへ乗り換え</div>
                            </div>
                        </div>
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div style="margin: 1rem 0;">
                            <div style="font-size: 0.85rem; margin-bottom: 0.8rem; color: rgba(255,255,255,0.7); text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;">乗り換え後のリニモを選択</div>
                            <div style="display: flex; flex-direction: row; gap: 0.5rem; background-color: rgba(255,255,255,0.08); padding: 0.4rem; border-radius: 10px; border: 1px solid rgba(255,255,255,0.15); flex-wrap: wrap;" class="linimo-segment-container">
                    `;

                    route.linimo_options.forEach((option, index) => {
                        const isSelected = index === 0;
                        html += `
                            <label style="flex: 1 1 calc(33.333% - 0.4rem); min-width: 90px; margin: 0; cursor: pointer;" class="linimo-segment-label">
                                <input type="radio" name="linimo_option_${route.shuttle_departure}"
                                       value="${index}"
                                       data-route='${JSON.stringify(route)}'
                                       data-index="${index}"
                                       ${isSelected ? 'checked' : ''}
                                       style="display: none;">
                                <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; background-color: ${isSelected ? 'rgba(255,255,255,0.15)' : 'transparent'}; border: 1px solid ${isSelected ? 'rgba(255,255,255,0.3)' : 'transparent'}; cursor: pointer;" class="linimo-segment-button">
                                    <div style="font-size: 1.05rem; font-weight: 700; color: white; margin-bottom: 0.3rem;">
                                        ${escapeHtml(option.linimo_departure)}
                                    </div>
                                    <div style="font-size: 0.8rem; color: rgba(255,255,255,0.8);">
                                        着${escapeHtml(option.destination_arrival)}
                                    </div>
                                </div>
                            </label>
                        `;
                    });

                    html += `
                            </div>
                        </div>
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step arrival-step" data-shuttle-departure="${route.shuttle_departure.replace(/:/g, '-')}">
                            <img src="assets/image/flag-2-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time arrival-time-display">${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds(route.linimo_options[0].destination_arrival))}</div>
                                <div class="route-step-detail">到着</div>
                            </div>
                        </div>
                    </div>
                    `;
                } else {
                    html += `
                    `;
                }
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
                `;

                // シャトルバス選択ウィジェット（八草駅→大学）
                if (route.shuttle_options && route.shuttle_options.length > 0) {
                    html += `
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div style="margin: 1rem 0;">
                            <div style="font-size: 0.85rem; margin-bottom: 0.8rem; color: rgba(255,255,255,0.7); text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;">シャトルバスを選択</div>
                            <div style="display: flex; flex-direction: row; gap: 0.5rem; background-color: rgba(255,255,255,0.08); padding: 0.4rem; border-radius: 10px; border: 1px solid rgba(255,255,255,0.15); flex-wrap: wrap;" class="shuttle-segment-container">
                    `;

                    route.shuttle_options.forEach((option, index) => {
                        const isSelected = index === 0;
                        html += `
                            <label style="flex: 1 1 calc(33.333% - 0.4rem); min-width: 90px; margin: 0; cursor: pointer;" class="shuttle-segment-label">
                                <input type="radio" name="shuttle_option_${route.shuttle_departure}"
                                       value="${index}"
                                       data-route='${JSON.stringify(route)}'
                                       data-index="${index}"
                                       ${isSelected ? 'checked' : ''}
                                       style="display: none;">
                                <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; background-color: ${isSelected ? 'rgba(255,255,255,0.15)' : 'transparent'}; border: 1px solid ${isSelected ? 'rgba(255,255,255,0.3)' : 'transparent'}; cursor: pointer;" class="shuttle-segment-button">
                                    <div style="font-size: 1.05rem; font-weight: 700; color: white; margin-bottom: 0.3rem;">
                                        ${escapeHtml(option.shuttle_departure)}
                                    </div>
                                    <div style="font-size: 0.8rem; color: rgba(255,255,255,0.8);">
                                        着${escapeHtml(option.shuttle_arrival)}
                                    </div>
                                </div>
                            </label>
                        `;
                    });

                    html += `
                            </div>
                        </div>
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step arrival-step" data-shuttle-departure="${route.shuttle_departure.replace(/:/g, '-')}">
                            <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time arrival-time-display">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_options[0].shuttle_arrival))}</div>
                                <div class="route-step-detail">到着</div>
                            </div>
                        </div>
                    </div>
                    `;
                } else {
                    html += `
                    `;
                }
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
                `;

                // シャトルバス選択ウィジェット（リニモ駅→大学）
                if (route.shuttle_options && route.shuttle_options.length > 0) {
                    html += `
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step transfer-time-step" data-linimo-departure="${route.linimo_departure.replace(/:/g, '-')}">
                            <img src="assets/image/time-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time transfer-time-display">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                                <div class="route-step-detail">シャトルバスへ乗り換え</div>
                            </div>
                        </div>
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div style="margin: 1rem 0;">
                            <div style="font-size: 0.85rem; margin-bottom: 0.8rem; color: rgba(255,255,255,0.7); text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;">シャトルバスを選択</div>
                            <div style="display: flex; flex-direction: row; gap: 0.5rem; background-color: rgba(255,255,255,0.08); padding: 0.4rem; border-radius: 10px; border: 1px solid rgba(255,255,255,0.15); flex-wrap: wrap;" class="shuttle-segment-container">
                    `;

                    route.shuttle_options.forEach((option, index) => {
                        const isSelected = index === 0;
                        html += `
                            <label style="flex: 1 1 calc(33.333% - 0.4rem); min-width: 90px; margin: 0; cursor: pointer;" class="shuttle-segment-label">
                                <input type="radio" name="shuttle_option_${route.linimo_departure}"
                                       value="${index}"
                                       data-route='${JSON.stringify(route)}'
                                       data-index="${index}"
                                       data-direction="to_university"
                                       ${isSelected ? 'checked' : ''}
                                       style="display: none;">
                                <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; background-color: ${isSelected ? 'rgba(255,255,255,0.15)' : 'transparent'}; border: 1px solid ${isSelected ? 'rgba(255,255,255,0.3)' : 'transparent'}; cursor: pointer;" class="shuttle-segment-button">
                                    <div style="font-size: 1.05rem; font-weight: 700; color: white; margin-bottom: 0.3rem;">
                                        ${escapeHtml(option.shuttle_departure)}
                                    </div>
                                    <div style="font-size: 0.8rem; color: rgba(255,255,255,0.8);">
                                        着${escapeHtml(option.shuttle_arrival)}
                                    </div>
                                </div>
                            </label>
                        `;
                    });

                    html += `
                            </div>
                        </div>
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step arrival-step" data-linimo-departure="${route.linimo_departure.replace(/:/g, '-')}">
                            <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time arrival-time-display">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_options[0].shuttle_arrival))}</div>
                                <div class="route-step-detail">到着</div>
                            </div>
                        </div>
                    </div>
                    `;
                } else {
                    html += `
                    `;
                }
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
    function renderNoService(serviceInfo, diaDescription) {
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

        // 背景色と文字色を設定
        const bgColor = serviceInfo.bg_color || '#0052a3';
        const textColor = serviceInfo.text_color || '#ffffff';
        const errorMessageStyle = `style="background: linear-gradient(135deg, ${bgColor}, ${bgColor}); color: ${textColor}; border: none; text-align: center; padding: 2rem 1.5rem; border-radius: 12px; box-shadow: 0 4px 12px rgba(0, 102, 204, 0.3);"`;

        let html = `<div class="error-message" ${errorMessageStyle}>`;

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
            if (diaDescription) {
                html += `
                    <p style="font-size: 0.9em; margin-top: 8px; opacity: 0.9;">
                        ${escapeHtml(diaDescription)}
                    </p>
                `;
            }
        } else if (serviceInfo.is_after_service) {
            html += `<strong>🌙 本日の運行は終了しました</strong>`;
            if (serviceInfo.last) {
                html += `<p>最終便: ${escapeHtml(serviceInfo.last)} 発（${escapeHtml(serviceInfo.direction_text)}）</p>`;
            }
            if (diaDescription) {
                html += `
                    <p style="font-size: 0.9em; margin-top: 8px; opacity: 0.9;">
                        ${escapeHtml(diaDescription)}
                    </p>
                `;
            }
            if (serviceInfo.next_day_first) {
                // 翌日の日付を取得
                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                const formattedDate = formatDate(tomorrow);

                html += `
                    <p style="margin-top: 12px; padding-top: 12px; border-top: 1px solid rgba(255,255,255,0.2);">
                        翌日始発: <strong>${escapeHtml(serviceInfo.next_day_first)} 発</strong>（${formattedDate}、${escapeHtml(serviceInfo.direction_text)}）
                    </p>
                `;

                // 翌日のダイヤ情報を表示
                if (serviceInfo.next_day_dia_type) {
                    html += `
                        <p style="font-size: 0.9em; margin-top: 8px; opacity: 0.9;">
                            ダイヤ${escapeHtml(serviceInfo.next_day_dia_type)}
                            ${serviceInfo.next_day_dia_description ? `（${escapeHtml(serviceInfo.next_day_dia_description)}）` : ''}
                        </p>
                    `;
                }
            }
        }

        html += '</div>';
        container.innerHTML = html;
        container.style.display = 'block';
    }

    /**
     * 日付をフォーマット（YYYY年MM月DD日）
     */
    function formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}年${month}月${day}日`;
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

    /**
     * シャトルバス選択時の動的更新
     */
    window.updateShuttleChoice = function(radio, route, selectedIndex) {
        if (!radio.checked || !route.shuttle_options || !route.shuttle_options[selectedIndex]) {
            return;
        }

        const selectedOption = route.shuttle_options[selectedIndex];

        // ルート詳細内の情報を更新
        const container = radio.closest('.next-departure-details') || radio.closest('.route-card-compact');
        if (!container) return;

        // セグメンテッドコントロールのボタンの見た目を更新
        const allLabels = container.querySelectorAll('.shuttle-segment-label');
        allLabels.forEach((label, index) => {
            const labelDiv = label.querySelector('div');
            if (labelDiv) {
                if (index === selectedIndex) {
                    labelDiv.style.backgroundColor = 'rgba(255,255,255,0.15)';
                    labelDiv.style.border = '1px solid rgba(255,255,255,0.3)';
                } else {
                    labelDiv.style.backgroundColor = 'transparent';
                    labelDiv.style.border = '1px solid transparent';
                }
            }
        });

        // 大学到着時刻を更新
        const safeId = radio.name.replace(/shuttle_option_/, '').replace(/:/g, '-');

        // 八草駅→大学のケース
        const arrivalStepShuttle = container.querySelector(`.arrival-step[data-shuttle-departure="${safeId}"]`);
        if (arrivalStepShuttle) {
            const arrivalTimeDisplay = arrivalStepShuttle.querySelector('.arrival-time-display');
            if (arrivalTimeDisplay) {
                arrivalTimeDisplay.textContent = `愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(selectedOption.shuttle_arrival))}`;
            }
        }

        // リニモ駅→大学のケース
        const arrivalStepLinimo = container.querySelector(`.arrival-step[data-linimo-departure="${safeId}"]`);
        if (arrivalStepLinimo) {
            const arrivalTimeDisplay = arrivalStepLinimo.querySelector('.arrival-time-display');
            if (arrivalTimeDisplay) {
                arrivalTimeDisplay.textContent = `愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(selectedOption.shuttle_arrival))}`;
            }
        }

        // リニモ駅→大学の乗り換え時間を更新
        const transferTimeStepLinimo = container.querySelector(`.transfer-time-step[data-linimo-departure="${safeId}"]`);
        if (transferTimeStepLinimo) {
            const transferTimeDisplay = transferTimeStepLinimo.querySelector('.transfer-time-display');
            if (transferTimeDisplay) {
                transferTimeDisplay.textContent = `乗り換え時間: ${escapeHtml(selectedOption.transfer_time)}分`;
            }
        }

        // サマリーの総所要時間と乗り換え時間を更新
        const summaryDiv = container.querySelector('.route-summary');
        if (summaryDiv) {
            const summaryItems = summaryDiv.querySelectorAll('.summary-item');
            summaryItems.forEach((item) => {
                const label = item.querySelector('.summary-label');
                const value = item.querySelector('.summary-value');
                if (label && label.textContent.includes('総所要時間') && value) {
                    value.textContent = `${escapeHtml(selectedOption.total_time)}分`;
                } else if (label && label.textContent.includes('乗り換え') && value) {
                    value.textContent = `${escapeHtml(selectedOption.transfer_time)}分`;
                }
            });
        }
    };

    /**
     * リニモ選択時の動的更新
     */
    window.updateLinimoChoice = function(radio, route, selectedIndex) {
        if (!radio.checked || !route.linimo_options || !route.linimo_options[selectedIndex]) {
            return;
        }

        const selectedOption = route.linimo_options[selectedIndex];

        // ルート詳細内の情報を更新
        const container = radio.closest('.next-departure-details') || radio.closest('.route-card-compact');
        if (!container) return;

        // セグメンテッドコントロールのボタンの見た目を更新
        const allLabels = container.querySelectorAll('label');
        allLabels.forEach((label, index) => {
            const labelDiv = label.querySelector('div');
            if (labelDiv) {
                if (index === selectedIndex) {
                    labelDiv.style.backgroundColor = 'rgba(255,255,255,0.15)';
                    labelDiv.style.border = '1px solid rgba(255,255,255,0.3)';
                } else {
                    labelDiv.style.backgroundColor = 'transparent';
                    labelDiv.style.border = '1px solid transparent';
                }
            }
        });

        // 目的地到着時刻を更新
        const safeId = route.shuttle_departure.replace(/:/g, '-');
        const arrivalStep = container.querySelector(`.arrival-step[data-shuttle-departure="${safeId}"]`);
        if (arrivalStep) {
            const arrivalTimeDisplay = arrivalStep.querySelector('.arrival-time-display');
            if (arrivalTimeDisplay) {
                arrivalTimeDisplay.textContent = `${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds(selectedOption.destination_arrival))}`;
            }
        }

        // 乗り換え時間を更新
        const transferTimeStep = container.querySelector(`.transfer-time-step[data-shuttle-departure="${safeId}"]`);
        if (transferTimeStep) {
            const transferTimeDisplay = transferTimeStep.querySelector('.transfer-time-display');
            if (transferTimeDisplay) {
                transferTimeDisplay.textContent = `乗り換え時間: ${escapeHtml(selectedOption.transfer_time)}分`;
            }
        }

        // サマリーの総所要時間を更新
        const summaryDiv = container.querySelector('.route-summary');
        if (summaryDiv) {
            const summaryItems = summaryDiv.querySelectorAll('.summary-item');
            summaryItems.forEach((item) => {
                const label = item.querySelector('.summary-label');
                const value = item.querySelector('.summary-value');
                if (label && label.textContent.includes('総所要時間') && value) {
                    value.textContent = `${escapeHtml(selectedOption.total_time)}分`;
                } else if (label && label.textContent.includes('乗り換え') && value) {
                    value.textContent = `${escapeHtml(selectedOption.transfer_time)}分`;
                }
            });
        }
    };
})();

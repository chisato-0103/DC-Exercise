/**
 * 愛知工業大学 交通情報システム
 * トップページ（index.html）用スクリプト
 */

(function () {
    'use strict';

    let stations = [];
    let currentDirection = 'to_station';
    let currentLineCode = 'linimo';
    let currentDestination = 'fujigaoka';
    let currentOrigin = 'fujigaoka';

    /**
     * URLパラメータを取得
     */
    function getURLParams() {
        const params = new URLSearchParams(window.location.search);
        const direction = params.get('direction') || 'to_station';
        const lineCode = params.get('line_code') || 'linimo';

        // direction に基づいて、対応するパラメータのみを取得
        let destination = null;
        let origin = null;

        if (direction === 'to_station') {
            // 大学 → 駅の場合は destination のみ使用
            destination = params.get('destination') || 'fujigaoka';
        } else if (direction === 'to_university') {
            // 駅 → 大学の場合は origin のみ使用
            origin = params.get('origin') || 'fujigaoka';
        }

        // テスト用パラメータを取得
        const testDate = params.get('test_date');
        const testTime = params.get('test_time');

        return {
            direction: direction,
            lineCode: lineCode,
            destination: destination,
            origin: origin,
            testDate: testDate,
            testTime: testTime
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

            // 路線別に駅をフィルタリング
            const filterStationsByLine = (lineCode) => {
                return stations.filter(station => {
                    if (lineCode === 'linimo') {
                        // リニモ駅のみ（8駅）か転乗ハブの八草
                        return station.line_type === 'linimo' || station.station_code === 'yakusa';
                    } else if (lineCode === 'aichi_kanjo') {
                        // 愛知環状線駅（23駅: 岡崎→高蔵寺）+ 八草駅（転乗ハブ）
                        return station.line_type === 'aichi_kanjo' || station.station_code === 'yakusa';
                    }
                    return true;
                });
            };

            const updateStationSelects = (lineCode) => {
                const destinationSelect = document.getElementById('destination');
                const originSelect = document.getElementById('origin');
                const filteredStations = filterStationsByLine(lineCode);

                // 駅を order_index でソート（実際の駅の順番）
                const sortedStations = [...filteredStations].sort((a, b) => {
                    const indexA = a.order_index || 0;
                    const indexB = b.order_index || 0;
                    return indexA - indexB;
                });

                // 目的地オプション
                const destinationOptions = sortedStations
                    .map(station => `
                        <option value="${escapeHtml(station.station_code)}">
                            ${escapeHtml(station.station_name)}
                        </option>
                    `).join('');

                // 出発地オプション（八草を含める）
                const originOptions = sortedStations
                    .map(station => `
                        <option value="${escapeHtml(station.station_code)}">
                            ${escapeHtml(station.station_name)}
                        </option>
                    `).join('');

                if (destinationSelect) destinationSelect.innerHTML = destinationOptions;
                if (originSelect) originSelect.innerHTML = originOptions;
            };

            // リニモを初期状態で表示
            updateStationSelects('linimo');
            // グローバルにupdateStationSelectsを公開（後で使用）
            window.updateStationSelects = updateStationSelects;

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
        currentLineCode = params.lineCode;
        currentDestination = params.destination;
        currentOrigin = params.origin;

        try {
            const data = await API.getNextConnection(
                currentDirection,
                currentLineCode,
                currentDirection === 'to_station' ? currentDestination : null,
                currentDirection === 'to_university' ? currentOrigin : null,
                params.testDate,
                params.testTime
            );

            // 現在時刻とダイヤ情報を更新
            updateCurrentTimeDisplay(data);

            // フォーム値を復元
            document.getElementById('direction').value = currentDirection;
            document.getElementById('line_code').value = currentLineCode;

            // ラジオボタンを復元
            let routeOption = 'to_linimo';  // デフォルト
            if (currentDirection === 'to_university') {
                routeOption = currentLineCode === 'aichi_kanjo' ? 'from_aichi_kanjo' : 'from_linimo';
            } else {
                routeOption = currentLineCode === 'aichi_kanjo' ? 'to_aichi_kanjo' : 'to_linimo';
            }
            const radioButton = document.querySelector(`input[name="route_option"][value="${routeOption}"]`);
            if (radioButton) {
                radioButton.checked = true;
            }

            // 駅を更新
            if (window.updateStationSelects) {
                window.updateStationSelects(currentLineCode);
            }

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

        const { routes, from_name, to_name, service_info, dia_description, direction, line_code } = apiResponse.data;

        // APIから返された direction を使用（これがサーバーで確定した値）
        const renderDirection = direction || currentDirection;
        const renderLineCode = line_code || currentLineCode;

        // 次の便（最初のルート）
        if (routes && routes.length > 0) {
            renderNextDeparture(routes[0], renderDirection, renderLineCode);
            renderOtherRoutes(routes.slice(1), renderDirection, renderLineCode);
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
    function renderNextDeparture(route, direction, lineCode = 'linimo') {
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
                ${renderRouteDetails(route, direction, lineCode)}
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

        // リニモ選択ラジオボタンにイベントリスナーを追加（ルート１）
        setTimeout(() => {
            const radioButtons = container.querySelectorAll('input[type="radio"][name^="linimo_option_"]');
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

            // シャトルバス選択ウィジェット用のイベントリスナーを追加（ルート１）
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
     * リニモ/愛知環状線選択時に到着時刻を更新
     */
    function updateLinimoChoice(radioButton, route, selectedIndex) {
        const railOptions = route.rail_options || route.linimo_options || [];
        if (selectedIndex < 0 || selectedIndex >= railOptions.length) {
            return;
        }

        const selectedOption = railOptions[selectedIndex];
        const container = radioButton.closest('.linimo-segment-container');

        // 到着時刻を更新
        const arrivalTimeDisplay = container
            ?.parentElement?.nextElementSibling?.nextElementSibling?.querySelector('.arrival-time-display');

        if (arrivalTimeDisplay) {
            const destination = route.destination_name || '';
            const arrivalTime = formatTimeWithoutSeconds(selectedOption.destination_arrival);
            arrivalTimeDisplay.textContent = `${escapeHtml(destination)} 着 ${escapeHtml(arrivalTime)}`;
        }

        // 総所要時間を更新（ルート１の場合）
        const totalTimeDisplay = document.querySelector('.next-departure .route-total-time');
        if (totalTimeDisplay && selectedOption.total_time) {
            totalTimeDisplay.textContent = `${escapeHtml(selectedOption.total_time)}分`;
        }

        // 乗り換え時間を更新
        const transferTimeDisplay = container
            ?.parentElement?.previousElementSibling?.previousElementSibling?.querySelector('.transfer-time-display');
        if (transferTimeDisplay && selectedOption.transfer_time !== undefined) {
            transferTimeDisplay.textContent = `乗り換え時間: ${escapeHtml(selectedOption.transfer_time)}分`;
        }
    }

    /**
     * シャトルバス選択時に到着時刻を更新（駅→大学の場合）
     */
    function updateShuttleChoice(radioButton, route, selectedIndex) {
        const shuttleOptions = route.shuttle_options || [];
        if (selectedIndex < 0 || selectedIndex >= shuttleOptions.length) {
            return;
        }

        const selectedOption = shuttleOptions[selectedIndex];
        const container = radioButton.closest('.shuttle-segment-container');

        // 到着時刻を更新
        const arrivalTimeDisplay = container
            ?.parentElement?.nextElementSibling?.nextElementSibling?.querySelector('.arrival-time-display');

        if (arrivalTimeDisplay) {
            const arrivalTime = formatTimeWithoutSeconds(selectedOption.shuttle_arrival);
            arrivalTimeDisplay.textContent = `愛知工業大学 着 ${escapeHtml(arrivalTime)}`;
        }

        // 総所要時間を更新（ルート１の場合）
        const totalTimeDisplay = document.querySelector('.next-departure .route-total-time');
        if (totalTimeDisplay && selectedOption.total_time) {
            totalTimeDisplay.textContent = `${escapeHtml(selectedOption.total_time)}分`;
        }

        // 乗り換え時間を更新
        const transferTimeDisplay = container
            ?.parentElement?.previousElementSibling?.previousElementSibling?.querySelector('.transfer-time-display');
        if (transferTimeDisplay && selectedOption.transfer_time !== undefined) {
            transferTimeDisplay.textContent = `乗り換え時間: ${escapeHtml(selectedOption.transfer_time)}分`;
        }
    }

    /**
     * ルート詳細を生成
     */
    function renderRouteDetails(route, direction, lineCode = 'linimo') {
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

                // 路線別の選択ウィジェット
                const railOptions = lineCode === 'aichi_kanjo' ? route.rail_options : route.linimo_options;
                const railName = lineCode === 'aichi_kanjo' ? '愛知環状線' : 'リニモ';

                if (railOptions && railOptions.length > 0) {
                    html += `
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step transfer-time-step" data-shuttle-departure="${route.shuttle_departure.replace(/:/g, '-')}">
                            <img src="assets/image/time-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time transfer-time-display">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                                <div class="route-step-detail">${railName}へ乗り換え</div>
                            </div>
                        </div>
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div style="margin: 1rem 0;">
                            <div style="font-size: 0.85rem; margin-bottom: 0.8rem; color: rgba(255,255,255,0.7); text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;">乗り換え後の${railName}を選択</div>
                            <div style="display: flex; flex-direction: row; gap: 0.5rem; background-color: rgba(255,255,255,0.08); padding: 0.4rem; border-radius: 10px; border: 1px solid rgba(255,255,255,0.15); flex-wrap: wrap;" class="linimo-segment-container">
                    `;

                    railOptions.forEach((option, index) => {
                        const isSelected = index === 0;
                        const railDepartureField = lineCode === 'aichi_kanjo' ? 'rail_departure' : 'linimo_departure';
                        html += `
                            <label style="flex: 1 1 calc(33.333% - 0.4rem); min-width: 90px; margin: 0; cursor: pointer;" class="linimo-segment-label">
                                <input type="radio" name="linimo_option_${route.shuttle_departure}"
                                       value="${index}"
                                       data-route='${JSON.stringify(route)}'
                                       data-index="${index}"
                                       ${isSelected ? 'checked' : ''}
                                       style="display: none;">
                                <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; cursor: pointer;" class="linimo-segment-button">
                                    <div style="font-size: 1.05rem; font-weight: 700; color: white; margin-bottom: 0.3rem;">
                                        ${escapeHtml(option[railDepartureField])}
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
                            <img src="assets/image/flag-2-svgrepo-com.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time arrival-time-display">${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds(railOptions[0].destination_arrival))}</div>
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

                // 八草駅→大学の場合は、シャトルバス選択肢なしでシンプルに表示
                html += `
                    <div class="route-arrow" style="color: white;">↓</div>
                    <div class="route-step">
                        <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
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
                `;

                // シャトルバス選択ウィジェット（リニモ駅→大学 または 愛知環状線駅→大学）
                if (route.shuttle_options && route.shuttle_options.length > 0) {
                    const railDeparture = route.linimo_departure || route.rail_departure;
                    html += `
                        <div class="route-arrow" style="color: white;">↓</div>
                        <div class="route-step transfer-time-step" data-linimo-departure="${railDeparture.replace(/:/g, '-')}">
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
                                <input type="radio" name="shuttle_option_${railDeparture}"
                                       value="${index}"
                                       data-route='${JSON.stringify(route)}'
                                       data-index="${index}"
                                       data-direction="to_university"
                                       ${isSelected ? 'checked' : ''}
                                       style="display: none;">
                                <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; cursor: pointer;" class="shuttle-segment-button">
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
                        <div class="route-step arrival-step" data-linimo-departure="${railDeparture.replace(/:/g, '-')}">
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
    function renderOtherRoutes(routes, direction, lineCode = 'linimo') {
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
                <div class="route-card-compact" data-route-index="${index}">
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
                        ${renderCompactRouteSteps(route, direction, lineCode)}
                    </div>
                </div>
            `;
        });

        container.innerHTML = html;
        container.style.display = 'block';

        // すべてのイベントリスナーを一度に登録
        setTimeout(() => {
            // route-card-compact のクリックで展開/閉鎖
            const routeCards = container.querySelectorAll('.route-card-compact');
            routeCards.forEach((card) => {
                card.addEventListener('click', function (e) {
                    // セグメントコンテナ内のクリックは無視
                    if (e.target.closest('.linimo-segment-container') || e.target.closest('.shuttle-segment-container')) {
                        return;
                    }
                    this.classList.toggle('expanded');
                });
            });

            // リニモセグメントボタンのクリックイベント（ラベル経由）
            const allLinimoSegmentLabels = container.querySelectorAll('.linimo-segment-container .linimo-segment-label');
            allLinimoSegmentLabels.forEach((label) => {
                label.addEventListener('click', function (e) {
                    e.stopPropagation();
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio) {
                        radio.checked = true;
                        radio.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                });
            });

            // シャトルバスセグメントボタンのクリックイベント（ラベル経由）
            const allShuttleSegmentLabels = container.querySelectorAll('.shuttle-segment-container .shuttle-segment-label');
            allShuttleSegmentLabels.forEach((label) => {
                label.addEventListener('click', function (e) {
                    e.stopPropagation();
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio) {
                        radio.checked = true;
                        radio.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                });
            });

            // リニモラジオボタンのchangeイベント
            const allLinimoRadios = container.querySelectorAll('.linimo-segment-container input[type="radio"]');
            allLinimoRadios.forEach((radio) => {
                radio.addEventListener('change', function () {
                    const route = JSON.parse(this.getAttribute('data-route'));
                    const selectedIndex = parseInt(this.getAttribute('data-index'));
                    updateLinimoChoice(this, route, selectedIndex);
                }, true); // キャプチャフェーズで実行
            });

            // シャトルバスラジオボタンのchangeイベント
            const allShuttleRadios = container.querySelectorAll('.shuttle-segment-container input[type="radio"]');
            allShuttleRadios.forEach((radio) => {
                radio.addEventListener('change', function () {
                    const route = JSON.parse(this.getAttribute('data-route'));
                    const selectedIndex = parseInt(this.getAttribute('data-index'));
                    updateShuttleChoice(this, route, selectedIndex);
                }, true); // キャプチャフェーズで実行
            });

            // スマホ時は縦並びに（幅が600px以下の場合）
            if (window.innerWidth <= 600) {
                const allLabels = container.querySelectorAll('.linimo-segment-label, .shuttle-segment-label');
                allLabels.forEach((label) => {
                    label.style.flex = '1 1 100%';
                    label.style.minWidth = 'unset';
                });
            }
        }, 0);
    }

    /**
     * コンパクトルート詳細を生成
     */
    function renderCompactRouteSteps(route, direction, lineCode = 'linimo') {
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
                <div class="route-step transfer-time-step" data-shuttle-departure="${route.shuttle_departure.replace(/:/g, '-')}">
                    <img src="assets/image/time-svgrepo-com.svg" />
                    <div class="route-step-content">
                        <div class="route-step-time transfer-time-display">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                        <div class="route-step-detail">${lineCode === 'aichi_kanjo' ? '愛知環状線' : 'リニモ'}へ乗り換え</div>
                    </div>
                </div>
                <div class="route-arrow">↓</div>
                ${(route.rail_options || route.linimo_options) && (route.rail_options || route.linimo_options).length > 0 ? `
                    <div style="margin: 1rem 0; padding: 1rem; border: 2px solid #0066cc; border-radius: 12px; background-color: #f9fbff;">
                        <div style="font-size: 0.85rem; margin-bottom: 0.8rem; color: #0066cc; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;">乗り換え後の${lineCode === 'aichi_kanjo' ? '愛知環状線' : 'リニモ'}を選択</div>
                        <div style="display: flex; flex-direction: row; gap: 0.5rem; padding: 0; border-radius: 8px; flex-wrap: wrap;" class="linimo-segment-container">
                            ${(route.rail_options || route.linimo_options).map((option, index) => {
                                const isSelected = index === 0;
                                const railDepartureField = lineCode === 'aichi_kanjo' ? 'rail_departure' : 'linimo_departure';
                                return `
                                    <label style="flex: 1 1 calc(33.333% - 0.4rem); min-width: 90px; margin: 0; cursor: pointer;" class="linimo-segment-label">
                                        <input type="radio" name="linimo_option_${route.shuttle_departure}"
                                               value="${index}"
                                               data-route='${JSON.stringify(route)}'
                                               data-index="${index}"
                                               ${isSelected ? 'checked' : ''}
                                               style="position: absolute; opacity: 0; width: 0; height: 0; pointer-events: none;">
                                        <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; cursor: pointer;" class="linimo-segment-button">
                                            <div style="font-size: 1.05rem; font-weight: 700; color: #666; margin-bottom: 0.3rem;">
                                                ${escapeHtml(option[railDepartureField])}
                                            </div>
                                            <div style="font-size: 0.8rem; color: #999;">
                                                着${escapeHtml(option.destination_arrival)}
                                            </div>
                                        </div>
                                    </label>
                                `;
                            }).join('')}
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step arrival-step" data-shuttle-departure="${route.shuttle_departure.replace(/:/g, '-')}">
                        <img src="assets/image/flag-2-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time arrival-time-display">${escapeHtml(route.destination_name)} 着 ${escapeHtml(formatTimeWithoutSeconds((route.rail_options || route.linimo_options)[0].destination_arrival))}</div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                ` : `
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
                `}
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
                // リニモ駅 → 大学 または 愛知環状線駅 → 大学
                const railDepartureField = lineCode === 'aichi_kanjo' ? 'rail_departure' : 'linimo_departure';
                const railArrivalField = lineCode === 'aichi_kanjo' ? 'rail_arrival' : 'linimo_arrival';
                const railTimeField = lineCode === 'aichi_kanjo' ? 'rail_time' : 'linimo_time';

                const railDeparture = route[railDepartureField];
                const railArrival = route[railArrivalField];
                const railTime = route[railTimeField];
                html = `
                    <div class="route-step">
                        <img src="assets/image/train-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">${escapeHtml(route.origin_name)} 発 ${escapeHtml(formatTimeWithoutSeconds(railDeparture))}</div>
                            <div class="route-step-detail">${lineCode === 'aichi_kanjo' ? '愛知環状線' : 'リニモ'}で出発</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step">
                        <img src="assets/image/train-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 着 ${escapeHtml(formatTimeWithoutSeconds(railArrival))}</div>
                            <div class="route-step-detail">${lineCode === 'aichi_kanjo' ? '愛知環状線' : 'リニモ'}約${escapeHtml(railTime)}分</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    <div class="route-step transfer-time-step" data-linimo-departure="${railDeparture.replace(/:/g, '-')}">
                        <img src="assets/image/time-svgrepo-com.svg" />
                        <div class="route-step-content">
                            <div class="route-step-time transfer-time-display">乗り換え時間: ${escapeHtml(route.transfer_time)}分</div>
                            <div class="route-step-detail">シャトルバスへ乗り換え</div>
                        </div>
                    </div>
                    <div class="route-arrow">↓</div>
                    ${route.shuttle_options && route.shuttle_options.length > 0 ? `
                        <div style="margin: 1rem 0; padding: 1rem; border: 2px solid #0066cc; border-radius: 12px; background-color: #f9fbff;">
                            <div style="font-size: 0.85rem; margin-bottom: 0.8rem; color: #0066cc; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;">シャトルバスを選択</div>
                            <div style="display: flex; flex-direction: row; gap: 0.5rem; padding: 0; border-radius: 8px; flex-wrap: wrap;" class="shuttle-segment-container">
                                ${route.shuttle_options.map((option, index) => {
                                    const isSelected = index === 0;
                                    return `
                                        <label style="flex: 1 1 calc(33.333% - 0.4rem); min-width: 90px; margin: 0; cursor: pointer;" class="shuttle-segment-label">
                                            <input type="radio" name="shuttle_option_${railDeparture}"
                                                   value="${index}"
                                                   data-route='${JSON.stringify(route)}'
                                                   data-index="${index}"
                                                   data-direction="to_university"
                                                   ${isSelected ? 'checked' : ''}
                                                   style="position: absolute; opacity: 0; width: 0; height: 0; pointer-events: none;">
                                            <div style="padding: 1rem 0.8rem; border-radius: 8px; text-align: center; transition: all 0.2s ease; cursor: pointer;" class="shuttle-segment-button">
                                                <div style="font-size: 1.05rem; font-weight: 700; color: #666; margin-bottom: 0.3rem;">
                                                    ${escapeHtml(option.shuttle_departure)}
                                                </div>
                                                <div style="font-size: 0.8rem; color: #999;">
                                                    着${escapeHtml(option.shuttle_arrival)}
                                                </div>
                                            </div>
                                        </label>
                                    `;
                                }).join('')}
                            </div>
                        </div>
                        <div class="route-arrow">↓</div>
                        <div class="route-step arrival-step" data-linimo-departure="${railDeparture.replace(/:/g, '-')}">
                            <img src="assets/image/school-flag-svgrepo-com 2.svg" />
                            <div class="route-step-content">
                                <div class="route-step-time arrival-time-display">愛知工業大学 着 ${escapeHtml(formatTimeWithoutSeconds(route.shuttle_options[0].shuttle_arrival))}</div>
                                <div class="route-step-detail">到着</div>
                            </div>
                        </div>
                    ` : `
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
                    `}
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
        const destinationSelect = document.getElementById('destination');
        const originSelect = document.getElementById('origin');

        if (direction === 'to_station') {
            destinationGroup.style.display = '';
            originGroup.style.display = 'none';
            // 非表示の origin を form 送信から除外
            originSelect.disabled = true;
            destinationSelect.disabled = false;
        } else {
            destinationGroup.style.display = 'none';
            originGroup.style.display = '';
            // 非表示の destination を form 送信から除外
            destinationSelect.disabled = true;
            originSelect.disabled = false;
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
        if (!route.shuttle_options || !route.shuttle_options[selectedIndex]) {
            return;
        }

        const selectedOption = route.shuttle_options[selectedIndex];

        // ルート詳細内の情報を更新
        const container = radio.closest('.next-departure-details') || radio.closest('.route-card-compact') || radio.closest('.route-steps');
        if (!container) return;

        // セグメンテッドコントロールのボタンの見た目を更新
        // 同じラジオボタングループ内のラベルのみを対象にする
        const parentContainer = radio.closest('.shuttle-segment-container');

        if (parentContainer) {
            const allRadios = parentContainer.querySelectorAll('input[type="radio"]');
            allRadios.forEach((r) => {
                const label = r.closest('.shuttle-segment-label');
                if (label) {
                    const labelDiv = label.querySelector('.shuttle-segment-button');
                    if (labelDiv) {
                        if (r === radio) {
                            // 選択されたラジオボタンに対応するボタン
                            labelDiv.style.backgroundColor = r.closest('.next-departure-details') ? 'rgba(255,255,255,0.15)' : '#e8f0fe';
                            labelDiv.style.border = r.closest('.next-departure-details') ? '1px solid rgba(255,255,255,0.3)' : '1px solid #0066cc';
                            // 子要素のテキスト色も更新
                            const timeText = labelDiv.querySelector('div:first-child');
                            const arrivalText = labelDiv.querySelector('div:last-child');
                            if (timeText) timeText.style.color = r.closest('.next-departure-details') ? 'white' : '#0066cc';
                            if (arrivalText) arrivalText.style.color = r.closest('.next-departure-details') ? 'rgba(255,255,255,0.8)' : '#0066cc';
                        } else {
                            // 未選択のボタン
                            labelDiv.style.backgroundColor = 'transparent';
                            labelDiv.style.border = '1px solid transparent';
                            const timeText = labelDiv.querySelector('div:first-child');
                            const arrivalText = labelDiv.querySelector('div:last-child');
                            if (timeText) timeText.style.color = r.closest('.next-departure-details') ? 'white' : '#666';
                            if (arrivalText) arrivalText.style.color = r.closest('.next-departure-details') ? 'rgba(255,255,255,0.8)' : '#999';
                        }
                    }
                }
            });
        }

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
        if (!route.linimo_options || !route.linimo_options[selectedIndex]) {
            return;
        }

        const selectedOption = route.linimo_options[selectedIndex];

        // ルート詳細内の情報を更新
        const container = radio.closest('.next-departure-details') || radio.closest('.route-card-compact') || radio.closest('.route-steps');
        if (!container) return;

        // セグメンテッドコントロールのボタンの見た目を更新
        // 同じラジオボタングループ内のラベルのみを対象にする
        const parentContainer = radio.closest('.linimo-segment-container');

        if (parentContainer) {
            const allRadios = parentContainer.querySelectorAll('input[type="radio"]');
            allRadios.forEach((r) => {
                const label = r.closest('.linimo-segment-label');
                if (label) {
                    const labelDiv = label.querySelector('.linimo-segment-button');
                    if (labelDiv) {
                        if (r === radio) {
                            // 選択されたラジオボタンに対応するボタン
                            labelDiv.style.backgroundColor = r.closest('.next-departure-details') ? 'rgba(255,255,255,0.15)' : '#e8f0fe';
                            labelDiv.style.border = r.closest('.next-departure-details') ? '1px solid rgba(255,255,255,0.3)' : '1px solid #0066cc';
                            // 子要素のテキスト色も更新
                            const timeText = labelDiv.querySelector('div:first-child');
                            const arrivalText = labelDiv.querySelector('div:last-child');
                            if (timeText) timeText.style.color = r.closest('.next-departure-details') ? 'white' : '#0066cc';
                            if (arrivalText) arrivalText.style.color = r.closest('.next-departure-details') ? 'rgba(255,255,255,0.8)' : '#0066cc';
                        } else {
                            // 未選択のボタン
                            labelDiv.style.backgroundColor = 'transparent';
                            labelDiv.style.border = '1px solid transparent';
                            const timeText = labelDiv.querySelector('div:first-child');
                            const arrivalText = labelDiv.querySelector('div:last-child');
                            if (timeText) timeText.style.color = r.closest('.next-departure-details') ? 'white' : '#666';
                            if (arrivalText) arrivalText.style.color = r.closest('.next-departure-details') ? 'rgba(255,255,255,0.8)' : '#999';
                        }
                    }
                }
            });
        }

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

    /**
     * 路線と方向を設定する
     */
    window.setRouteOption = function(routeOption) {
        let direction, lineCode;

        switch (routeOption) {
            case 'to_linimo':
                direction = 'to_station';
                lineCode = 'linimo';
                break;
            case 'from_linimo':
                direction = 'to_university';
                lineCode = 'linimo';
                break;
            case 'to_aichi_kanjo':
                direction = 'to_station';
                lineCode = 'aichi_kanjo';
                break;
            case 'from_aichi_kanjo':
                direction = 'to_university';
                lineCode = 'aichi_kanjo';
                break;
            default:
                direction = 'to_station';
                lineCode = 'linimo';
        }

        // 隠し入力フィールドを更新
        document.getElementById('direction').value = direction;
        document.getElementById('line_code').value = lineCode;

        // 駅を更新
        if (window.updateStationSelects) {
            window.updateStationSelects(lineCode);
        }

        // 方向に応じて表示を切り替え
        toggleDirectionFields(direction);
    };
})();

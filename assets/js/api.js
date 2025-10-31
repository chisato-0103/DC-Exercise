/**
 * 愛知工業大学 交通情報システム
 * API呼び出しモジュール
 */

const API = (function() {
    'use strict';

    const BASE_URL = '';

    /**
     * APIリクエストの共通処理
     * @param {string} endpoint - APIエンドポイント
     * @param {Object} params - クエリパラメータ
     * @returns {Promise<Object>} - APIレスポンス
     */
    async function fetchAPI(endpoint, params = {}) {
        try {
            const url = new URL(endpoint, window.location.href);
            Object.keys(params).forEach(key => {
                if (params[key] !== null && params[key] !== undefined) {
                    url.searchParams.append(key, params[key]);
                }
            });

            const response = await fetch(url.toString());

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.error || 'API request failed');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    /**
     * 次の乗り継ぎルートを取得
     * @param {string} direction - 方向 ('to_station' or 'to_university')
     * @param {string} lineCode - 路線コード ('linimo' or 'aichi_kanjo')
     * @param {string} destination - 目的地駅コード (direction='to_station'の場合)
     * @param {string} origin - 出発地駅コード (direction='to_university'の場合)
     * @returns {Promise<Object>} - ルート情報
     */
    async function getNextConnection(direction, lineCode = 'linimo', destination = null, origin = null) {
        const params = { direction, line_code: lineCode };

        if (direction === 'to_station' && destination) {
            params.destination = destination;
        } else if (direction === 'to_university' && origin) {
            params.origin = origin;
        }

        return await fetchAPI('api/get_next_connection.php', params);
    }

    /**
     * 乗り継ぎルートを検索
     * @param {string} direction - 方向 ('to_station' or 'to_university')
     * @param {string} from - 出発地
     * @param {string} to - 目的地
     * @param {string} time - 出発時刻 (HH:MM形式、省略時は現在時刻)
     * @returns {Promise<Object>} - 検索結果
     */
    async function searchConnection(direction, from, to, time = null) {
        const params = { direction, from, to };

        if (time) {
            params.time = time;
        }

        return await fetchAPI('api/search_connection.php', params);
    }

    /**
     * 全駅リストを取得
     * @returns {Promise<Array>} - 駅リスト
     */
    async function getStations() {
        const data = await fetchAPI('api/get_stations.php');
        return data.stations || [];
    }

    /**
     * アクティブなお知らせを取得
     * @param {string} type - お知らせタイプ ('all', 'shuttle', 'linimo')
     * @returns {Promise<Array>} - お知らせリスト
     */
    async function getNotices(type = 'all') {
        const data = await fetchAPI('api/get_notices.php', { type });
        return data.notices || [];
    }

    // 公開API
    return {
        getNextConnection,
        searchConnection,
        getStations,
        getNotices
    };
})();

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String provider = (String)session.getAttribute("provider");
    
    // 관리자 권한 확인
    if(loginId == null || !"admin".equals(provider)) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신고 관리 - WhereHot Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .admin-container { margin-top: 30px; }
        .report-table th { background-color: #f8f9fa; }
        .status-badge { font-size: 0.8em; }
        .reason-badge { font-size: 0.7em; }
        .loading { text-align: center; padding: 50px; }
        .report-content { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    </style>
</head>
<body>
    <div class="container admin-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="page-title"><i class="bi bi-flag-fill me-2"></i>신고 관리</h2>
            <a href="<%=root%>/WEB-INF/views/adminpage/admin.jsp" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> 관리자 메인
            </a>
        </div>

        <!-- 통계 정보 -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <h5>전체 신고</h5>
                        <h2 id="totalReports">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-danger text-white">
                    <div class="card-body">
                        <h5>미처리 신고</h5>
                        <h2 id="pendingReports">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h5>처리 완료</h5>
                        <h2 id="processedReports">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-secondary text-white">
                    <div class="card-body">
                        <h5>거부됨</h5>
                        <h2 id="rejectedReports">-</h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 필터 -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">상태</label>
                        <select id="statusFilter" class="form-select">
                            <option value="">전체</option>
                            <option value="pending">미처리</option>
                            <option value="processed">처리완료</option>
                            <option value="rejected">거부됨</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">신고 사유</label>
                        <select id="reasonFilter" class="form-select">
                            <option value="">전체</option>
                            <option value="spam">스팸/광고</option>
                            <option value="inappropriate">부적절한 내용</option>
                            <option value="abuse">욕설/비방</option>
                            <option value="copyright">저작권 침해</option>
                            <option value="other">기타</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">페이지 크기</label>
                        <select id="pageSize" class="form-select">
                            <option value="10">10개</option>
                            <option value="20" selected>20개</option>
                            <option value="50">50개</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <button class="btn btn-primary d-block w-100" onclick="loadReports()">
                            <i class="bi bi-search"></i> 조회
                        </button>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <button class="btn btn-success d-block w-100" onclick="loadReports()">
                            <i class="bi bi-arrow-clockwise"></i> 새로고침
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 신고 목록 -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">신고 목록</h5>
                <span id="reportCount" class="badge bg-secondary">총 0건</span>
            </div>
            <div class="card-body">
                <div id="reportListContainer">
                    <div class="loading">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">로딩중...</span>
                        </div>
                        <p class="mt-2">신고 목록을 불러오는 중...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 페이지네이션 -->
        <nav id="paginationContainer" class="mt-4" style="display: none;">
            <ul class="pagination justify-content-center" id="pagination">
            </ul>
        </nav>
    </div>

    <!-- 신고 상세 모달 -->
    <div class="modal fade" id="reportDetailModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">신고 상세 정보</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="reportDetailContent">
                    <!-- 상세 내용이 여기에 로드됩니다 -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                    <button type="button" class="btn btn-success" onclick="processReport()" id="processBtn">처리 완료</button>
                    <button type="button" class="btn btn-danger" onclick="rejectReport()" id="rejectBtn">거부</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentPage = 0;
        let currentSize = 20;
        let currentReportId = null;

        // 페이지 로드시 초기화
        $(document).ready(function() {
            showApiNotice();
        });

        // API 미구현 안내
        function showApiNotice() {
            $('#reportListContainer').html(`
                <div class="alert alert-info">
                    <h5><i class="bi bi-info-circle"></i> 신고 관리 API 구현 필요</h5>
                    <p>신고 관리 기능을 위해 다음 API들이 구현되어야 합니다:</p>
                    <ul>
                        <li><code>GET /api/admin/reports</code> - 신고 목록 조회</li>
                        <li><code>GET /api/admin/reports/stats</code> - 신고 통계</li>
                        <li><code>PUT /api/admin/reports/{id}/process</code> - 신고 처리</li>
                        <li><code>PUT /api/admin/reports/{id}/reject</code> - 신고 거부</li>
                        <li><code>GET /api/admin/reports/{id}</code> - 신고 상세 조회</li>
                    </ul>
                    <p class="mb-0">현재는 기본 UI만 구현되어 있습니다.</p>
                </div>
                
                <div class="alert alert-warning">
                    <h6>기존 Model1 구조에서 변경사항:</h6>
                    <ul class="mb-0">
                        <li>Hottalk_ReportDao → ReportService + ReportMapper</li>
                        <li>HpostDao → PostService + PostMapper</li>
                        <li>JSP 직접 DB 호출 → REST API 호출</li>
                        <li>페이지 새로고침 → AJAX 동적 로딩</li>
                    </ul>
                </div>
            `);
        }

        // 신고 통계 로드 (구현 예정)
        function loadReportStats() {
            // TODO: API 구현 필요
            $('#totalReports').text('N/A');
            $('#pendingReports').text('N/A');
            $('#processedReports').text('N/A');
            $('#rejectedReports').text('N/A');
        }

        // 신고 목록 로드 (구현 예정)
        function loadReports(page = 0) {
            // TODO: API 구현 필요
            alert('신고 관리 API가 구현되지 않았습니다.\n다음 엔드포인트 구현이 필요합니다:\nGET /api/admin/reports');
        }

        // 신고 처리 (구현 예정)
        function processReport() {
            if (!currentReportId) return;
            
            // TODO: API 구현 필요
            alert('신고 처리 API가 구현되지 않았습니다.\n엔드포인트: PUT /api/admin/reports/' + currentReportId + '/process');
        }

        // 신고 거부 (구현 예정)
        function rejectReport() {
            if (!currentReportId) return;
            
            // TODO: API 구현 필요
            alert('신고 거부 API가 구현되지 않았습니다.\n엔드포인트: PUT /api/admin/reports/' + currentReportId + '/reject');
        }

        // 신고 상세 조회 (구현 예정)
        function viewReportDetail(reportId) {
            currentReportId = reportId;
            
            // TODO: API 구현 필요
            $('#reportDetailContent').html(`
                <div class="alert alert-info">
                    <p>신고 상세 조회 API가 구현되지 않았습니다.</p>
                    <p>엔드포인트: <code>GET /api/admin/reports/${reportId}</code></p>
                </div>
            `);
            
            $('#reportDetailModal').modal('show');
        }

        // 유틸리티 함수들
        function getReasonText(reason) {
            const reasons = {
                'spam': '스팸/광고',
                'inappropriate': '부적절한 내용',
                'abuse': '욕설/비방',
                'copyright': '저작권 침해',
                'other': '기타'
            };
            return reasons[reason] || '기타';
        }

        function getStatusText(status) {
            const statuses = {
                'pending': '미처리',
                'processed': '처리완료',
                'rejected': '거부됨'
            };
            return statuses[status] || '알수없음';
        }

        function getStatusColor(status) {
            const colors = {
                'pending': 'warning',
                'processed': 'success',
                'rejected': 'secondary'
            };
            return colors[status] || 'primary';
        }

        function formatDate(dateString) {
            if (!dateString) return '-';
            const date = new Date(dateString);
            return date.toLocaleDateString('ko-KR') + ' ' + date.toLocaleTimeString('ko-KR');
        }
    </script>
</body>
</html>
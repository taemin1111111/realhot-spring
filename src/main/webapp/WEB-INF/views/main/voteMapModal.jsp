<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = "";
%>
<script>
    
// 투표 모달 표시 함수 (map.jsp 전용)
function showVoteModal(hotplaceId, name, address, categoryId) {
    // 모달이 이미 있으면 제거
    const existingModal = document.getElementById('voteModal');
    if (existingModal) {
        existingModal.remove();
    }
    
    // 모달 HTML 생성
    const modalHtml = 
        '<div id="voteModal" class="modal fade" tabindex="-1" style="display: block !important; background: rgba(0,0,0,0.8) !important; position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 99999; visibility: visible !important; opacity: 1 !important;">' +
            '<div class="modal-dialog modal-dialog-centered" style="z-index: 100000;">' +
                '<div class="modal-content" style="border-radius: 20px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">' +
                    '<div class="modal-header" style="border-bottom: 1px solid #e9ecef; padding: 20px 24px 16px 24px;">' +
                        '<h5 class="modal-title" style="font-weight: 600; color: #333; margin: 0;">🔥 투표하기</h5>' +
                        '<button type="button" class="btn-close" onclick="closeVoteModal()" style="background: none; border: none; font-size: 1.5rem; color: #999; cursor: pointer; padding: 0; width: 30px; height: 30px; display: flex; align-items: center; justify-content: center;">&times;</button>' +
                    '</div>' +
                    '<div class="modal-body" style="padding: 24px;">' +
                        '<div style="margin-bottom: 20px;">' +
                            '<h6 style="color: #333; margin-bottom: 8px; font-weight: 600;">' + name + '</h6>' +
                            '<p style="color: #666; margin: 0; font-size: 0.9rem;">' + address + '</p>' +
                        '</div>' +
                        '<form id="voteForm">' +
                            '<input type="hidden" name="hotplaceId" value="' + hotplaceId + '">' +
                            '<div style="margin-bottom: 20px;">' +
                                '<label style="display: block; margin-bottom: 8px; font-weight: 500; color: #333;">혼잡도는 어떤가요?</label>' +
                                '<div style="display: flex; gap: 8px; flex-wrap: wrap;">' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="crowd" value="1" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">여유</span>' +
                                    '</label>' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="crowd" value="2" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">보통</span>' +
                                    '</label>' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="crowd" value="3" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">혼잡</span>' +
                                    '</label>' +
                                '</div>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px;">' +
                                '<label style="display: block; margin-bottom: 8px; font-weight: 500; color: #333;">대기시간은 얼마나 되나요?</label>' +
                                '<div style="display: flex; gap: 8px; flex-wrap: wrap;">' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="wait" value="1" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">없음</span>' +
                                    '</label>' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="wait" value="2" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">10분이하</span>' +
                                    '</label>' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="wait" value="3" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">30분이상</span>' +
                                    '</label>' +
                                '</div>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px;">' +
                                '<label style="display: block; margin-bottom: 8px; font-weight: 500; color: #333;">성비는 어떤가요?</label>' +
                                '<div style="display: flex; gap: 8px; flex-wrap: wrap;">' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="gender" value="3" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">남성 많음</span>' +
                                    '</label>' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="gender" value="2" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">비슷함</span>' +
                                    '</label>' +
                                    '<label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 8px 12px; border: 2px solid #e9ecef; border-radius: 8px; transition: all 0.2s; flex: 1; min-width: 0; justify-content: center;">' +
                                        '<input type="radio" name="gender" value="1" style="margin: 0;">' +
                                        '<span style="font-size: 0.9rem;">여성 많음</span>' +
                                    '</label>' +
                                '</div>' +
                            '</div>' +
                            '<div id="voteStatusMessage" style="margin-bottom: 16px; padding: 12px; border-radius: 8px; display: none;"></div>' +
                            '<div style="display: flex; gap: 8px;">' +
                                '<button type="button" onclick="closeVoteModal()" class="btn btn-outline-secondary" style="flex: 1; padding: 12px; border-radius: 8px; font-weight: 500;">취소</button>' +
                                '<button type="submit" class="btn btn-primary" style="flex: 1; padding: 12px; border-radius: 8px; font-weight: 500; background: #1275E0; border-color: #1275E0;">투표하기</button>' +
                            '</div>' +
                        '</form>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>';
    
    // 모달을 body에 추가
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    
    // 라디오 버튼 스타일링
    const labels = document.querySelectorAll('#voteModal label');
    labels.forEach(label => {
        const radio = label.querySelector('input[type="radio"]');
        if (radio) {
            radio.addEventListener('change', function() {
                // 모든 라벨의 스타일 초기화
                labels.forEach(l => {
                    l.style.borderColor = '#e9ecef';
                    l.style.backgroundColor = 'transparent';
                    l.style.color = '#333';
                });
                
                // 선택된 라벨 스타일 적용
                if (this.checked) {
                    label.style.borderColor = '#1275E0';
                    label.style.backgroundColor = '#f0f8ff';
                    label.style.color = '#1275E0';
                }
            });
        }
    });
    
    // 폼 이벤트 리스너 설정
    setupVoteForm();
}

// 투표 모달 닫기 함수
function closeVoteModal() {
    const modal = document.getElementById('voteModal');
    if (modal) {
        modal.remove();
    }
}

// 투표 폼 설정 함수
function setupVoteForm() {
    const form = document.getElementById('voteForm');
    const statusMessage = document.getElementById('voteStatusMessage');
    
    if (!form) return;
    
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const formData = new FormData(form);
        const hotplaceId = formData.get('hotplaceId');
        const crowd = formData.get('crowd');
        const wait = formData.get('wait');
        const gender = formData.get('gender');
        
        // 검증
        if (!hotplaceId) {
            showVoteMessage('먼저 지도에서 장소를 선택해주세요.', 'warning');
            return;
        }
        
        if (!crowd || !wait || !gender) {
            showVoteMessage('모든 질문에 답변해주세요.', 'warning');
            return;
        }
        
        // JWT 토큰 가져오기
        const token = getToken();
        
        // Spring API 호출 (JWT 토큰 포함)
        const data = new URLSearchParams();
        data.append('hotplaceId', hotplaceId);
        data.append('crowd', crowd);
        data.append('gender', gender);
        data.append('wait', wait);
        
        const headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
        };
        
        // 토큰이 있으면 Authorization 헤더 추가
        if (token) {
            headers['Authorization'] = 'Bearer ' + token;
        }
        
        // 투표 전송
        fetch('<%=root%>/api/vote/now-hot', {
            method: 'POST',
            headers: headers,
            body: data
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                showVoteMessage('투표가 완료되었습니다! 감사합니다.', 'success');
                setTimeout(() => {
                    closeVoteModal();
                }, 1500);
            } else {
                showVoteMessage(result.message || '투표 중 오류가 발생했습니다.', 'error');
            }
        })
        .catch(error => {
            console.error('Vote error:', error);
            showVoteMessage('투표 중 오류가 발생했습니다.', 'error');
        });
    });
}

// 투표 메시지 표시 함수
function showVoteMessage(message, type) {
    const statusMessage = document.getElementById('voteStatusMessage');
    if (!statusMessage) return;
    
    statusMessage.style.display = 'block';
    statusMessage.textContent = message;
    
    // 타입에 따른 스타일 적용
    statusMessage.style.backgroundColor = type === 'success' ? '#d4edda' : 
                                        type === 'warning' ? '#fff3cd' : '#f8d7da';
    statusMessage.style.color = type === 'success' ? '#155724' : 
                               type === 'warning' ? '#856404' : '#721c24';
    statusMessage.style.border = type === 'success' ? '1px solid #c3e6cb' : 
                                type === 'warning' ? '1px solid #ffeaa7' : '1px solid #f5c6cb';
    
    // 3초 후 메시지 숨기기
    setTimeout(() => {
        statusMessage.style.display = 'none';
    }, 3000);
}

// JWT 토큰 가져오기 함수
function getToken() {
    return localStorage.getItem('accessToken') || sessionStorage.getItem('accessToken');
}
</script>

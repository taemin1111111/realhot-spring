<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = "";
%>

<div class="w-100">
    <h3 class="mb-4 fw-bold text-center">회원가입</h3>

    <form id="joinForm" onsubmit="return handleSignup(event)">
        <input type="hidden" name="provider" value="site">

        <!-- 아이디 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="userid" id="join-userid" class="form-control" placeholder="아이디" required>
                <button type="button" class="btn btn-outline-secondary" onclick="checkId()">중복확인</button>
            </div>
            <div id="join-idCheckResult" class="mt-1 small"></div>
        </div>

        <!-- 비밀번호 -->
        <div class="mb-3">
            <input type="password" name="passwd" id="join-passwd" class="form-control" placeholder="비밀번호" required>
            <div id="join-pwRuleResult" class="mt-1 small"></div>
        </div>

        <!-- 비밀번호 확인 -->
        <div class="mb-3">
            <input type="password" name="passwdConfirm" id="join-passwdConfirm" class="form-control" placeholder="비밀번호 확인" required>
            <div id="join-pwCheckResult" class="mt-1 small"></div>
        </div>

        <!-- 이름 -->
        <div class="mb-3">
            <input type="text" name="name" class="form-control" placeholder="이름" required>
        </div>

        <!-- 닉네임 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="nickname" id="join-nickname" class="form-control" 
                       maxlength="7" placeholder="닉네임 (2~7자)" required>
                <button type="button" class="btn btn-outline-secondary" onclick="checkNickname()">중복확인</button>
            </div>
            <div class="form-text text-muted">닉네임은 2~7자 사이로 입력해주세요.</div>
            <div id="join-nickCheckResult" class="mt-1 small"></div>
        </div>



        <!-- 이메일 (이메일 필수 + 인증코드 발송) -->
        <div class="mb-3">
            <div class="input-group">
                <input type="email" name="email" id="join-email" class="form-control" placeholder="이메일" required>
                <button type="button" class="btn btn-outline-primary" onclick="sendEmailCode()">인증요청</button>
            </div>
            <div id="join-emailResult" class="mt-1 small"></div>
        </div>

        <!-- 이메일 인증코드 입력 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="emailVerificationCode" id="join-emailCodeInput" class="form-control" placeholder="이메일 인증코드 입력" disabled required>
                <button type="button" class="btn btn-outline-success" onclick="verifyEmailCode()" disabled>확인</button>
            </div>
            <div id="join-emailCodeResult" class="mt-1 small"></div>
        </div>

        <!-- 생년월일 -->
        <div class="mb-3">
            <input type="date" name="birth" class="form-control">
        </div>

        <!-- 성별 -->
        <div class="mb-3">
            <select name="gender" class="form-select">
                <option value="">성별 선택</option>
                <option value="M">남자</option>
                <option value="F">여자</option>
            </select>
        </div>

        <!-- 약관동의 -->
        <div class="mb-3">
            <div class="form-check mb-2">
                <input class="form-check-input signup-terms-checkbox" type="checkbox" id="termsAgreement" required onclick="handleTermsCheckboxClick()">
                <label class="form-check-label" for="termsAgreement">
                    <span class="text-danger">[필수]</span> 이용약관 동의
                </label>
                <button type="button" class="btn btn-link btn-sm p-0 ms-2" onclick="showTermsModal()">내용보기</button>
            </div>
            
            <div class="form-check mb-2">
                <input class="form-check-input signup-privacy-checkbox" type="checkbox" id="privacyAgreement" required onclick="handlePrivacyCheckboxClick()">
                <label class="form-check-label" for="privacyAgreement">
                    <span class="text-danger">[필수]</span> 개인정보 수집 및 이용 동의
                </label>
                <button type="button" class="btn btn-link btn-sm p-0 ms-2" onclick="showPrivacyModal()">내용보기</button>
            </div>
        </div>

        <div class="d-flex gap-2">
            <button type="button" class="btn btn-secondary" onclick="showLogin()">뒤로가기</button>
            <button type="submit" class="btn btn-primary flex-fill">회원가입 완료</button>
        </div>
    </form>
</div>

<!-- 이용약관 모달 -->
<div class="modal fade" id="termsModal" tabindex="-1" aria-labelledby="termsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="termsModalLabel">이용약관</h5>
                <button type="button" class="btn-close" onclick="closeTermsModal()" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="max-height: 400px; overflow-y: auto;">
                <div class="terms-content">
                    <h6>제1조 (목적)</h6>
                    <p>본 약관은 "어디핫"(이하 "회사")이 제공하는 핫플레이스 정보 공유 및 커뮤니티 플랫폼(이하 "서비스")의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.</p>
                    
                    <h6>제2조 (정의)</h6>
                    <ul>
                        <li>"서비스"란 회사가 제공하는 웹/모바일 기반 핫플레이스 정보, 리뷰, 투표, 커뮤니티 등을 말합니다.</li>
                        <li>"회원"이란 본 약관에 동의하고 서비스를 이용하는 자를 말합니다.</li>
                        <li>"게시물"이란 회원이 서비스 내에 작성·게시한 텍스트, 이미지, 동영상, 댓글 등을 의미합니다.</li>
                    </ul>
                    
                    <h6>제3조 (약관의 효력 및 변경)</h6>
                    <ul>
                        <li>본 약관은 회원이 동의함으로써 효력이 발생합니다.</li>
                        <li>회사는 법령을 위반하지 않는 범위에서 약관을 변경할 수 있으며, 변경 시 시행 7일 전(중요 변경은 30일 전)부터 공지합니다.</li>
                        <li>회원이 변경된 약관에 동의하지 않을 경우, 서비스 이용을 중단하고 탈퇴할 수 있습니다.</li>
                    </ul>
                    
                    <h6>제4조 (회원가입 및 계정 관리)</h6>
                    <ul>
                        <li>회원가입은 아이디, 비밀번호, 이메일 등 필수 정보를 기재하고 본 약관 및 개인정보처리방침에 동의함으로써 성립합니다.</li>
                        <li>회원은 본인의 계정을 타인에게 양도·대여할 수 없으며, 관리 소홀로 인한 문제에 대한 책임은 본인에게 있습니다.</li>
                        <li>회사는 다음 사유가 있는 경우 가입을 거부하거나 취소할 수 있습니다.</li>
                        <ul>
                            <li>허위 정보 기재, 타인 정보 도용</li>
                            <li>사회질서를 해치는 목적으로 이용</li>
                            <li>기타 회사가 부적절하다고 판단하는 경우</li>
                        </ul>
                    </ul>
                    
                    <h6>제5조 (서비스의 제공 및 변경)</h6>
                    <p>회사는 다음 서비스를 제공합니다.</p>
                    <ul>
                        <li>핫플레이스 정보 제공 및 지도 기반 검색</li>
                        <li>후기/리뷰 작성, 별점, 추천 시스템</li>
                        <li>투표 및 인기 랭킹</li>
                        <li>커뮤니티(썰 게시판, 코스 추천, 같이갈 사람 등)</li>
                        <li>위시리스트 및 MD 제휴 정보</li>
                        <li>기타 회사가 정하는 서비스</li>
                    </ul>
                    <p>회사는 서비스 개선·운영상 필요에 따라 서비스 일부 또는 전부를 변경·중단할 수 있습니다.</p>
                    
                    <h6>제6조 (회원의 의무 및 금지행위)</h6>
                    <p>회원은 다음 행위를 해서는 안 됩니다.</p>
                    <ul>
                        <li>허위 정보 작성, 타인 개인정보 도용</li>
                        <li>음란물, 아동·청소년 유해 매체물, 폭력적·혐오적 게시물 게재</li>
                        <li>유흥업소, 퇴폐업소, 성매매 알선, 불법 도박 등 불법 행위 홍보</li>
                        <li>해당 행위 적발 시 즉시 게시물 삭제 및 아이디 영구 정지</li>
                        <li>타인의 명예 훼손, 모욕, 개인정보 노출, 저작권 침해</li>
                        <li>스팸, 상업적 광고 게시(사전 승인 없는 경우)</li>
                        <li>회사 서비스의 정상 운영을 방해하는 행위(해킹, 크롤링 등)</li>
                    </ul>
                    
                    <h6>제7조 (게시물의 권리와 책임)</h6>
                    <ul>
                        <li>게시물의 저작권은 작성자에게 귀속됩니다.</li>
                        <li>회원은 본인의 게시물로 인해 발생하는 모든 법적 책임을 부담합니다.</li>
                        <li>회사는 다음 사유가 있을 경우 사전 통보 없이 게시물을 삭제할 수 있습니다.</li>
                        <ul>
                            <li>법령 위반, 권리 침해, 음란/불법 게시물</li>
                            <li>유흥·퇴폐 업소 홍보 등 운영 정책 위반</li>
                        </ul>
                        <li>회사는 서비스 홍보 및 운영을 위해 필요한 범위 내에서 게시물을 비상업적으로 활용할 수 있습니다.</li>
                    </ul>
                    
                    <h6>제8조 (서비스 이용 제한 및 해지)</h6>
                    <ul>
                        <li>회사는 회원이 약관·법령을 위반한 경우 즉시 서비스 이용을 제한하거나 회원 자격을 박탈할 수 있습니다.</li>
                        <li>특히, 불법 행위(성매매, 퇴폐업소 홍보, 저작권 침해, 명예훼손 등)에 대해서는 사전 경고 없이 계정 영구 정지 및 법적 조치를 취할 수 있습니다.</li>
                        <li>회원은 언제든지 서비스 탈퇴를 요청할 수 있으며, 회사는 제재 이력 검토 후 관련 법령에 따라 보관기간 경과 시 개인정보를 파기합니다.</li>
                    </ul>
                    
                    <h6>제9조 (면책조항)</h6>
                    <ul>
                        <li>회사는 천재지변, 시스템 장애 등 불가항력으로 인한 서비스 중단에 대해 책임지지 않습니다.</li>
                        <li>회사는 회원 간 또는 회원과 제3자 간 분쟁에 개입하지 않으며, 그 결과에 대해 책임을 지지 않습니다.</li>
                        <li>회사는 게시물의 신뢰성, 정확성, 적법성에 대해 보증하지 않습니다.</li>
                    </ul>
                    
                    <h6>제10조 (준거법 및 관할법원)</h6>
                    <p>본 약관은 대한민국 법률에 따르며, 서비스 이용과 관련하여 발생하는 분쟁은 회사 본사 소재지 관할 법원을 제1심 전속 관할법원으로 합니다.</p>
                    
                    <p><strong>📌 시행일: 2025년 9월 10일</strong></p>
                </div>
            </div>
            <div class="modal-footer">
                <div class="form-check">
                    <input class="form-check-input signup-modal-terms-checkbox" type="checkbox" id="termsModalAgreement">
                    <label class="form-check-label" for="termsModalAgreement">
                        이용약관에 동의합니다
                    </label>
                </div>
                <button type="button" class="btn btn-primary" onclick="agreeTerms()">동의</button>
            </div>
        </div>
    </div>
</div>

<!-- 개인정보 수집 및 이용 동의 모달 -->
<div class="modal fade" id="privacyModal" tabindex="-1" aria-labelledby="privacyModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="privacyModalLabel">개인정보 수집 및 이용 동의</h5>
                <button type="button" class="btn-close" onclick="closePrivacyModal()" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="max-height: 400px; overflow-y: auto;">
                <div class="privacy-content">
                    <h6>제1조 (수집하는 개인정보 항목)</h6>
                    
                    <p><strong>필수 항목</strong></p>
                    <ul>
                        <li>아이디, 비밀번호, 닉네임, 이메일, 휴대폰 번호(본인인증 시)</li>
                        <li>서비스 이용 기록(접속 IP, 접속 로그, 쿠키 등)</li>
                    </ul>
                    
                    <p><strong>선택 항목</strong></p>
                    <ul>
                        <li>프로필 사진, 관심 지역, 성별, 생년월일</li>
                    </ul>
                    
                    <h6>제2조 (개인정보의 수집 및 이용 목적)</h6>
                    <p>회사는 수집한 개인정보를 다음 목적을 위해 이용합니다.</p>
                    <ul>
                        <li><strong>회원 가입 및 관리:</strong> 본인 확인, 중복가입 방지, 계정 관리</li>
                        <li><strong>서비스 제공:</strong> 후기 작성, 투표, 찜하기, 위시리스트, 커뮤니티 활동</li>
                        <li><strong>고객 지원:</strong> 공지, 알림, 민원 처리</li>
                        <li><strong>보안 관리:</strong> 불법 이용 방지, 비정상 이용 탐지 및 제재 이력 관리</li>
                    </ul>
                    
                    <h6>제3조 (개인정보의 보유 및 이용 기간)</h6>
                    <p>원칙적으로 회원이 탈퇴를 요청하면 지체 없이 개인정보를 파기합니다.</p>
                    <p>단, 다음의 경우에는 일정 기간 보관 후 파기합니다.</p>
                    <ul>
                        <li>운영 정책 위반, 서비스 제재 이력 검토를 위해 최대 30일간 임시 보관</li>
                        <li>전자상거래법에 따른 계약/결제 기록: 5년</li>
                        <li>전자상거래법에 따른 소비자 불만 및 분쟁 처리 기록: 3년</li>
                        <li>통신비밀보호법에 따른 접속 로그 기록: 3개월</li>
                    </ul>
                    <p>위 기간이 지나면 해당 정보는 지체 없이 안전하게 파기합니다.</p>
                    
                    <h6>제4조 (개인정보 제3자 제공 및 위탁)</h6>
                    <p>회사는 원칙적으로 회원 동의 없이 개인정보를 제3자에게 제공하지 않습니다.</p>
                    <p>서비스 운영을 위해 다음과 같이 위탁할 수 있습니다.</p>
                    <ul>
                        <li>이메일 발송: Brevo (Sendinblue)</li>
                        <li>소셜 로그인: 네이버 OAuth2</li>
                        <li>클라우드/호스팅: (사용 중인 서버 사업자 기재)</li>
                    </ul>
                    <p>회사는 위탁 계약 시 개인정보 보호 관련 법령을 준수합니다.</p>
                    
                    <h6>제5조 (동의 거부 권리 및 불이익)</h6>
                    <p>회원은 개인정보 수집·이용에 동의하지 않을 권리가 있습니다.</p>
                    <p>단, 필수 항목에 동의하지 않을 경우 회원가입 및 서비스 이용이 불가능합니다.</p>
                </div>
            </div>
            <div class="modal-footer">
                <div class="form-check">
                    <input class="form-check-input signup-modal-privacy-checkbox" type="checkbox" id="privacyModalAgreement">
                    <label class="form-check-label" for="privacyModalAgreement">
                        개인정보 수집 및 이용에 동의합니다
                    </label>
                </div>
                <button type="button" class="btn btn-primary" onclick="agreePrivacy()">동의</button>
            </div>
        </div>
    </div>
</div>

<script>
// ✅ 아이디 중복확인 (AJAX 연결)
function checkId() {
    const userid = document.getElementById("join-userid").value.trim();
    if(userid.length < 4) {
        document.getElementById("join-idCheckResult").textContent = "아이디는 최소 4자 이상 입력해주세요.";
        document.getElementById("join-idCheckResult").style.color = "red";
        return;
    }
    fetch("<%=root%>/api/auth/check/userid?userid=" + encodeURIComponent(userid))
        .then(res => res.json())
        .then(data => {
            if (!data.exists) {
                document.getElementById("join-idCheckResult").textContent = "사용가능한 아이디입니다.";
                document.getElementById("join-idCheckResult").style.color = "green";
            } else {
                document.getElementById("join-idCheckResult").textContent = "이미 사용중인 아이디입니다.";
                document.getElementById("join-idCheckResult").style.color = "red";
            }
        });
}

// ✅ 닉네임 중복확인 (AJAX 연결)
function checkNickname() {
    const nickname = document.getElementById("join-nickname").value.trim();
    if(nickname === "") {
        document.getElementById("join-nickCheckResult").textContent = "닉네임을 입력하세요.";
        document.getElementById("join-nickCheckResult").style.color = "red";
        return;
    }
    if(nickname.length < 2) {
        document.getElementById("join-nickCheckResult").textContent = "닉네임은 최소 2자 이상 입력해주세요.";
        document.getElementById("join-nickCheckResult").style.color = "red";
        return;
    }
    fetch("<%=root%>/api/auth/check/nickname?nickname=" + encodeURIComponent(nickname))
        .then(res => res.json())
        .then(data => {
            if (!data.exists) {
                document.getElementById("join-nickCheckResult").textContent = "사용가능한 닉네임입니다.";
                document.getElementById("join-nickCheckResult").style.color = "green";
            } else {
                document.getElementById("join-nickCheckResult").textContent = "이미 사용중인 닉네임입니다.";
                document.getElementById("join-nickCheckResult").style.color = "red";
                document.getElementById("join-nickname").value = "";
                document.getElementById("join-nickname").focus();
            }
        });
}



// ✅ 이메일 인증코드 발송 (이메일 중복 체크 포함)
function sendEmailCode() {
    const email = document.getElementById("join-email").value.trim();
    if(email === "") {
        document.getElementById("join-emailResult").innerText = "이메일을 입력하세요.";
        document.getElementById("join-emailResult").style.color = "red";
        return;
    }
    
    // 이메일 형식 검증
    const emailRegex = /^[A-Za-z0-9+_.-]+@(.+)$/;
    if (!emailRegex.test(email)) {
        document.getElementById("join-emailResult").innerText = "올바른 이메일 형식이 아닙니다.";
        document.getElementById("join-emailResult").style.color = "red";
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = "확인중...";
    
    // 먼저 이메일 중복 체크
    fetch("<%=root%>/api/auth/check/email?email=" + encodeURIComponent(email))
        .then(res => res.json())
        .then(data => {
            if (data.exists) {
                // 이메일 중복인 경우
                document.getElementById("join-emailResult").innerText = "해당 이메일로 가입된 계정이 있습니다.";
                document.getElementById("join-emailResult").style.color = "red";
                // 이메일 입력 필드 초기화
                document.getElementById("join-email").value = "";
                document.getElementById("join-email").focus();
                return;
            } else {
                // 이메일 중복이 아닌 경우, 기존 이메일 인증 프로세스 진행
                button.textContent = "발송중...";
                
                return fetch("<%=root%>/api/auth/email/send-verification", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "email=" + encodeURIComponent(email)
                });
            }
        })
        .catch(error => {
            throw new Error("이메일 중복 체크 중 오류가 발생했습니다.");
        })
        .then(res => {
            if (!res.ok) {
                // 오류 응답인 경우
                return res.json().then(errorData => {
                    throw new Error(errorData.error || "이메일 발송에 실패했습니다.");
                });
            }
            return res.json();
        })
        .then(data => {
            if (data.success) {
                document.getElementById("join-emailResult").innerText = data.message;
                document.getElementById("join-emailResult").style.color = "green";
                // 인증코드 입력 필드와 확인 버튼 활성화
                document.getElementById("join-emailCodeInput").disabled = false;
                document.getElementById("join-emailCodeInput").focus();
                document.querySelector('button[onclick="verifyEmailCode()"]').disabled = false;
            } else {
                document.getElementById("join-emailResult").innerText = data.message;
                document.getElementById("join-emailResult").style.color = "red";
            }
        })
        .catch(error => {
            document.getElementById("join-emailResult").innerText = error.message || "오류가 발생했습니다.";
            document.getElementById("join-emailResult").style.color = "red";
        })
        .finally(() => {
            // 버튼 다시 활성화
            button.disabled = false;
            button.textContent = originalText;
        });
}



// ✅ 이메일 인증코드 확인
function verifyEmailCode() {
    const email = document.getElementById("join-email").value.trim();
    const code = document.getElementById("join-emailCodeInput").value.trim();
    
    if(email === "") {
        document.getElementById("join-emailCodeResult").innerText = "이메일을 먼저 입력하세요.";
        document.getElementById("join-emailCodeResult").style.color = "red";
        return;
    }
    
    if(code === "") {
        document.getElementById("join-emailCodeResult").innerText = "인증코드를 입력하세요.";
        document.getElementById("join-emailCodeResult").style.color = "red";
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = "확인중...";
    
    fetch("<%=root%>/api/auth/email/verify", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "email=" + encodeURIComponent(email) + "&code=" + encodeURIComponent(code)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById("join-emailCodeResult").innerText = data.message;
            document.getElementById("join-emailCodeResult").style.color = "green";
            // 인증 완료 표시
            document.getElementById("join-email").readOnly = true;
            document.getElementById("join-emailCodeInput").readOnly = true;
            // 이메일 인증 완료 플래그 설정
            window.emailVerified = true;
        } else {
            document.getElementById("join-emailCodeResult").innerText = data.message;
            document.getElementById("join-emailCodeResult").style.color = "red";
        }
    })
    .catch(error => {
        document.getElementById("join-emailCodeResult").innerText = "오류가 발생했습니다.";
        document.getElementById("join-emailCodeResult").style.color = "red";
    })
    .finally(() => {
        // 버튼 다시 활성화
        button.disabled = false;
        button.textContent = originalText;
    });
}

// ✅ 비밀번호 검증
const pwInput = document.getElementById('join-passwd');
const pwRuleResult = document.getElementById('join-pwRuleResult');
pwInput.addEventListener("input", function() {
    const regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\[\]{};':"\\|,.<>\/?]).{10,}$/;
    if (pwInput.value === "") {
        pwRuleResult.textContent = "";
    } else if (regex.test(pwInput.value)) {
        pwRuleResult.textContent = "사용가능한 비밀번호입니다.";
        pwRuleResult.style.color = "green";
    } else {
        pwRuleResult.textContent = "10자 이상, 영문+숫자+특수문자 포함 필수";
        pwRuleResult.style.color = "red";
    }
});

// ✅ 비밀번호 일치검사
const pwConfirmInput = document.getElementById('join-passwdConfirm');
const pwCheckResult = document.getElementById('join-pwCheckResult');
pwConfirmInput.addEventListener("input", function() {
    if (pwInput.value === "" || pwConfirmInput.value === "") {
        pwCheckResult.textContent = "";
        return;
    }
    if (pwInput.value === pwConfirmInput.value) {
        pwCheckResult.textContent = "비밀번호가 일치합니다.";
        pwCheckResult.style.color = "green";
    } else {
        pwCheckResult.textContent = "비밀번호가 일치하지 않습니다.";
        pwCheckResult.style.color = "red";
    }
});

// 체크박스 클릭 시 모달 자동 열기
function handleTermsCheckboxClick() {
    const checkbox = document.getElementById('termsAgreement');
    if (checkbox.checked) {
        // 체크박스가 체크되면 모달 열기
        showTermsModal();
    }
}

function handlePrivacyCheckboxClick() {
    const checkbox = document.getElementById('privacyAgreement');
    if (checkbox.checked) {
        // 체크박스가 체크되면 모달 열기
        showPrivacyModal();
    }
}

// 모달 표시 함수들
function showTermsModal() {
    const modalElement = document.getElementById('termsModal');
    const modal = new bootstrap.Modal(modalElement, {
        backdrop: 'static',
        keyboard: false
    });
    
    // 모달 이벤트 리스너 추가 - 이벤트 전파 방지
    modalElement.addEventListener('hidden.bs.modal', function(event) {
        event.stopPropagation();
    });
    
    modal.show();
}

function showPrivacyModal() {
    const modalElement = document.getElementById('privacyModal');
    const modal = new bootstrap.Modal(modalElement, {
        backdrop: 'static',
        keyboard: false
    });
    
    // 모달 이벤트 리스너 추가 - 이벤트 전파 방지
    modalElement.addEventListener('hidden.bs.modal', function(event) {
        event.stopPropagation();
    });
    
    modal.show();
}

// 모달 닫기 함수들
function closeTermsModal() {
    const modalElement = document.getElementById('termsModal');
    const modal = bootstrap.Modal.getInstance(modalElement);
    if (modal) {
        modal.hide();
    }
    // 모달을 닫을 때 체크박스 해제 (동의하지 않은 경우)
    document.getElementById('termsAgreement').checked = false;
}

function closePrivacyModal() {
    const modalElement = document.getElementById('privacyModal');
    const modal = bootstrap.Modal.getInstance(modalElement);
    if (modal) {
        modal.hide();
    }
    // 모달을 닫을 때 체크박스 해제 (동의하지 않은 경우)
    document.getElementById('privacyAgreement').checked = false;
}

// 모달에서 동의 버튼 클릭 시 처리
function agreeTerms() {
    const modalAgreement = document.getElementById('termsModalAgreement');
    if (!modalAgreement.checked) {
        alert('이용약관에 동의해주세요.');
        return;
    }
    
    // 메인 체크박스 체크
    document.getElementById('termsAgreement').checked = true;
    
    // 모달 닫기
    const modalElement = document.getElementById('termsModal');
    const modal = bootstrap.Modal.getInstance(modalElement);
    if (modal) {
        modal.hide();
    }
}

function agreePrivacy() {
    const modalAgreement = document.getElementById('privacyModalAgreement');
    if (!modalAgreement.checked) {
        alert('개인정보 수집 및 이용에 동의해주세요.');
        return;
    }
    
    // 메인 체크박스 체크
    document.getElementById('privacyAgreement').checked = true;
    
    // 모달 닫기
    const modalElement = document.getElementById('privacyModal');
    const modal = bootstrap.Modal.getInstance(modalElement);
    if (modal) {
        modal.hide();
    }
}

// ✅ Spring Boot REST API 방식 회원가입 처리
async function handleSignup(event) {
    event.preventDefault();
    
    const pwRuleResult = document.getElementById('join-pwRuleResult');
    const pwCheckResult = document.getElementById('join-pwCheckResult');
    
    // 비밀번호 검증
    if (pwRuleResult.style.color !== "green" || pwCheckResult.style.color !== "green") {
        alert("비밀번호 조건 또는 비밀번호 확인을 다시 확인하세요.");
        return false;
    }
    
    // 이메일 인증 확인
    if (!window.emailVerified) {
        alert("이메일 인증을 완료해주세요.");
        return false;
    }
    
    // 약관 동의 확인
    const termsAgreement = document.getElementById('termsAgreement');
    const privacyAgreement = document.getElementById('privacyAgreement');
    
    if (!termsAgreement.checked) {
        alert("이용약관에 동의해주세요.");
        return false;
    }
    
    if (!privacyAgreement.checked) {
        alert("개인정보 수집 및 이용에 동의해주세요.");
        return false;
    }
    
    // 폼 데이터 수집
    const formData = new FormData(event.target);
    const signupData = {
        userid: formData.get('userid'),
        password: formData.get('passwd'),
        passwordConfirm: formData.get('passwdConfirm'),
        name: formData.get('name'),
        nickname: formData.get('nickname'),
        email: formData.get('email'),
        emailVerificationCode: formData.get('emailVerificationCode'),
        phone: formData.get('phone') || null,
        birth: formData.get('birth') || null,
        gender: formData.get('gender') || null,
        provider: 'site'
    };
    
    // 제출 버튼 비활성화
    const submitButton = event.target.querySelector('button[type="submit"]');
    const originalText = submitButton.textContent;
    submitButton.disabled = true;
    submitButton.textContent = '처리중...';
    
    try {
        const response = await fetch('<%=root%>/api/auth/signup', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(signupData)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            alert('회원가입이 완료되었습니다! 로그인해주세요.');
            // 로그인 폼으로 이동
            showLogin();
        } else {
            // 에러 응답 상세 정보 표시
            const errorMessage = result.message || result.error || '회원가입에 실패했습니다.';
            alert('회원가입 실패: ' + errorMessage);
        }
        
    } catch (error) {
        alert('회원가입 중 오류가 발생했습니다.');
    } finally {
        // 버튼 복구
        submitButton.disabled = false;
        submitButton.textContent = originalText;
    }
    
    return false;
}
</script>


1. Simulink (M파일)이 코드입니다.

2. EV_Modeling(시뮬링크 파일) 파일을 열었을 때 MATLAB 창에 코드가 안 나오시면 Simulink(M파일)을 넣어주시면 됩니다.

3. 데이터 추출 코드라고 나와있는 것은 Siumulink(M파일)에 이미 들어가 있습니다.
    Simulation_time = 23612 가 시뮬레이션 시간인데 시뮬링크 실행 시간에 맞춰서 바꿔주시면 됩니다. ( EV_Modeling 시뮬레이션 시간이 23612)

4. 실행을 누르시면 폴더에 data라는 엑셀 파일이 생성됩니다. 이 파일이 시뮬레이션 데이터 파일입니다.(시뮬레이션 실행 시 자동으로 생성 됩니다.)

5. MATLAB Simulink 메뉴얼에 P63~65를 보시면 시뮬레이션 시간 오류 부분을 추가해 넣었습니다.
   이 부분은 예를 들어 시뮬레이션 시간이 25000, 26000등 시뮬레이션 시간이 길어지면 오류가 나는 현상을 방지해 주는 설명입니다.
# annotation-using-matlab-imageLabeler

matlab > add-on > computer vision toolbox > imageLabeler

load > add images from folder

load > label definitions > load `cls18_def.mat`


# `mat2cvs.m`

이미지 폴더와 imageLabeler > export labels 통해 저장한 파일 지정

실행하면 Data/csv_temp와 Data/img 에 유효한 anno와 이미지 저장


# `check_anno.m`

57 lines `csvwrite([anno_save_dir, '\', name{1}, '.csv'], anno);` breakpoint 설정 후 실행

anno 값과 이미지 비교 후 저장 (잘림 여부, 어려움 여부 설정)

anno 수정 시 엔터 꼭 눌러야 수정됨

![image](https://user-images.githubusercontent.com/50072640/177679291-2e9edc5c-6717-4648-adb5-65bd032e4242.png)
![image](https://user-images.githubusercontent.com/50072640/177679496-9b075c4b-c407-40e8-bf77-1eaf4299309d.png)
![image](https://user-images.githubusercontent.com/50072640/177679490-d52ea0cc-8d00-4a84-90da-a7de35dcf54e.png)


# `obj_check.m`
obj 개수 안 고치고 넘어가는 경우가 있어 확인용으로 마지막에 돌리기

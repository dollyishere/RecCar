package com.heros.api.car.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class CarModify {
    @Schema(description = "carId", example = "1", required = true)
    private long carId;
    @Schema(description = "userId", example = "1", required = true)
    private long userId;
    @Schema(description = "자동차 번호", example = "12삼 4567")
    private String carNumber;
    @Schema(description = "자동차 제조사", example = "현대")
    private String carManufacturer;
    @Schema(description = "자동차 모델명", example = "쏘나타")
    private String carModel;
    @Schema(description = "자동차 연료", example = "식용유")
    private String carFuel;
    @Schema(description = "빌린 날짜", example = "2019-11-12T16:34:30.388")
    private LocalDateTime rentalDate;
    @Schema(description = "반납 날짜", example = "2019-11-12T16:34:30.388")
    private LocalDateTime returnDate;
    @Schema(description = "렌탈 회사", example = "쏘카")
    private String rentalCompany;
    @Schema(description = "대여 영상 주소", example = "rental.mp4")
    private String initialVideo;
    @Schema(description = "반납 영상 주소", example = "return.mp4")
    private String latterVideo;
}

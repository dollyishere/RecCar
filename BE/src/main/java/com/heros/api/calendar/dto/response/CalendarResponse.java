package com.heros.api.calendar.dto.response;

import com.heros.api.calendar.entity.Calendar;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;
import java.time.LocalDate;

@Data
@NoArgsConstructor
public class CalendarResponse {
    @Schema(description = "등록 날짜", example = "2023-03-12")
    @NotNull
    private LocalDate calendarDate;

    @Schema(description = "제목", example = "제목입니다.")
    @NotNull
    private String title;

    @Schema(description = "메모", example = "메모입니다.")
    @NotNull
    private String memo;

    @Schema(description = "자동 생성 일정", example = "false")
    @NotNull
    private boolean isAuto;

    public CalendarResponse(Calendar calendar) {
        this.calendarDate = calendar.getCalendarDate();
        this.title = calendar.getTitle();
        this.memo = calendar.getMemo();
        this.isAuto = calendar.isAuto();
    }
}

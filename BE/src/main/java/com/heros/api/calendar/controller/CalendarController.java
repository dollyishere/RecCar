package com.heros.api.calendar.controller;

import com.heros.api.calendar.dto.request.CalendarModifyRequest;
import com.heros.api.calendar.dto.request.CalendarRequest;
import com.heros.api.calendar.entity.Calendar;
import com.heros.api.calendar.service.CalendarService;
import com.heros.api.detectionInfo.dto.response.PartWithDetectionInfoResponse;
import com.heros.api.example.model.ErrorResponseExample;
import com.heros.exception.ErrorCode;
import com.heros.exception.customException.BusinessException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import java.util.List;

@Tag(name = "CalendarController", description = "캘린더 API")
@RestController
@RequestMapping("/api/v1/calendar/")
@RequiredArgsConstructor
public class CalendarController {

    private final CalendarService calendarService;

    @Operation(summary = "캘린더 조회")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "success", content = @Content(schema = @Schema(implementation = PartWithDetectionInfoResponse.class))),
            @ApiResponse(responseCode = "404", description = "fail", content = @Content(schema = @Schema(implementation = ErrorResponseExample.class)))
    })
    @GetMapping(value = "{userId}")
    public ResponseEntity<?> getCalender(@Schema(description = "조회할 userId", example = "1") @NotNull @Min(1) @PathVariable Long userId){
        List<Calendar> response = calendarService.getCalendar(userId);
        if (response.size() == 0) {
            throw (new BusinessException(ErrorCode.PAGE_NOT_FOUND));
        }
        return ResponseEntity.ok().body(response);
    }

    @Operation(summary = "캘린더 등록")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "success", content = @Content(schema = @Schema(implementation = PartWithDetectionInfoResponse.class))),
            @ApiResponse(responseCode = "404", description = "fail", content = @Content(schema = @Schema(implementation = ErrorResponseExample.class)))
    })
    @PostMapping(value = "")
    public ResponseEntity<?> calendarAdd(@Valid @RequestBody CalendarRequest calendarRequest) {
        calendarService.createCalendar(calendarRequest);
        return ResponseEntity.status(201).body(null);
    }

    @Operation(summary = "캘린더 수정")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "success", content = @Content(schema = @Schema(implementation = PartWithDetectionInfoResponse.class))),
            @ApiResponse(responseCode = "404", description = "fail", content = @Content(schema = @Schema(implementation = ErrorResponseExample.class)))
    })
    @PutMapping(value = "")
    public ResponseEntity<?> calendarUpdate(@Valid @RequestBody CalendarModifyRequest calendarModifyRequest) {
        calendarService.updateCalendar(calendarModifyRequest);
        return ResponseEntity.status(201).body(null);
    }

    @Operation(summary = "캘린더 삭제")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "success", content = @Content(schema = @Schema(implementation = PartWithDetectionInfoResponse.class))),
            @ApiResponse(responseCode = "404", description = "fail", content = @Content(schema = @Schema(implementation = ErrorResponseExample.class)))
    })
    @DeleteMapping(value = "{calendarId}")
    public ResponseEntity<?> calendarDelete(@Schema(description = "삭제할 calendar Id", example = "1") @NotNull @Min(1) @PathVariable Long calendarId) {
        calendarService.deleteCalendar(calendarId);
        return ResponseEntity.status(201).body(null);
    }
}

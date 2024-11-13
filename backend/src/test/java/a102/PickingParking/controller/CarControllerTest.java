package a102.PickingParking.controller;

import a102.PickingParking.entity.Car;
import a102.PickingParking.entity.User;
import a102.PickingParking.service.CarService;
import a102.PickingParking.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;

//@SpringBootTest
//@AutoConfigureMockMvc
@WebMvcTest(CarController.class)
class CarControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CarService carService;
    @MockBean
    private UserService userService;

    @BeforeEach
    public void setUp() {
        carService = Mockito.mock(CarService.class);
        userService = Mockito.mock(UserService.class);

        // ObjectMapper 설정
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule()); // LocalDateTime 지원 모듈 등록

        // MockMvc 설정
        mockMvc = MockMvcBuilders.standaloneSetup(new CarController(carService, userService))
                .setMessageConverters(new MappingJackson2HttpMessageConverter(objectMapper))
                .build();

    }

    @Test
    @DisplayName("자동차 추가 API 테스트")
    public void testRegisterCar() throws Exception {
        User user = new User();
        user.setSeq(1);
        user.setUserId("testUserId");
//        user.setPassword("testPassword");
//        user.setPhoneNumber("testPhoneNumber");

        Car car = new Car();
        car.setSeq(1);
        car.setPlate("12A3456");
        car.setSubmitImage("image.png");


        // UserService 모킹 설정
        when(userService.getUserByUserId("testUserId")).thenReturn(Optional.of(user));
        when(carService.registerCar(anyString(), any(Car.class))).thenReturn(car);

        mockMvc.perform(post("/api/car/{userId}", "testUserId")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(car)))
                .andDo(print()) // 요청 및 응답 출력
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.plate").value("12A3456"));
    }

    @Test
    @DisplayName("사용자 ID로 차량 목록 조회 API 테스트")
    public void testGetCars() throws Exception {
        User user = new User();
        user.setSeq(1);
        user.setUserId("testUserId");

        Car car1 = new Car();
        car1.setSeq(1);
        car1.setPlate("12A3456");
        car1.setSubmitImage("image1.png");

        Car car2 = new Car();
        car2.setSeq(2);
        car2.setPlate("34B5678");
        car2.setSubmitImage("image2.png");

        List<Car> carList = Arrays.asList(car1, car2);

        // UserService 모킹 설정
        when(userService.getUserByUserId("testUserId")).thenReturn(Optional.of(user));
        when(carService.getCarsByUser(anyString())).thenReturn(carList);

        mockMvc.perform(get("/api/car/{userId}", "testUserId"))
                .andDo(print()) // 요청 및 응답 출력
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2)) // 목록의 길이가 2인지 확인
                .andExpect(jsonPath("$[0].plate").value("12A3456")) // 첫 번째 차량의 번호판 확인
                .andExpect(jsonPath("$[1].plate").value("34B5678")); // 두 번째 차량의 번호판 확인
    }

    @Test
    @DisplayName("차량 상세 정보 조회 API 테스트")
    public void testGetCar() throws Exception {
        User user = new User();
        user.setSeq(1);
        user.setUserId("testUserId");

        Car car = new Car();
        car.setSeq(1);
        car.setPlate("12A3456");
        car.setSubmitImage("image.png");

        // UserService 모킹 설정
        when(userService.getUserByUserId("testUserId")).thenReturn(Optional.of(user));
        when(carService.getCarById(anyString(), any(Integer.class))).thenReturn(car);

        mockMvc.perform(get("/api/car/{userId}/{carId}", "testUserId", 1))
                .andDo(print()) // 요청 및 응답 출력
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.plate").value("12A3456")); // 차량의 번호판 확인
    }

}
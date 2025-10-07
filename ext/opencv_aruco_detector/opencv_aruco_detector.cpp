    #include <opencv2/objdetect/aruco_detector.hpp>
    #include <opencv2/videoio.hpp>
    #include <opencv2/highgui.hpp>
    #include <ruby.h>
    #include <stdlib.h>

    cv::VideoCapture inputVideo;
    cv::Mat inputImage;

    static VALUE detect_open(VALUE self)
    {
        inputVideo.open(1);
        if (!inputVideo.isOpened())
        {
            rb_raise(rb_eRuntimeError, "カメラの起動に失敗しました。");
            return Qfalse;
        }
        cv::namedWindow("red image", cv::WINDOW_AUTOSIZE);

        return Qtrue;
    }

    static VALUE detect_get(VALUE self)
    {
        cv::aruco::Dictionary dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_50);
        cv::aruco::DetectorParameters detectorParams = cv::aruco::DetectorParameters();
        cv::aruco::ArucoDetector detector = cv::aruco::ArucoDetector(dictionary, detectorParams);

        inputVideo >> inputImage;
        if (inputImage.empty())
        {
            rb_raise(rb_eRuntimeError, "画像の読み込みに失敗しました。");
            return Qnil;
        }
        cv::imshow("red image", inputImage);

        std::vector<int> markerIds;
        std::vector<std::vector<cv::Point2f>> markerCorners, rejectedCandidates;

        detector.detectMarkers(inputImage, markerCorners, markerIds, rejectedCandidates);
    
        VALUE arr = rb_ary_new();
        for (int i = 0; i < markerIds.size(); i++)
        {
            // clang-format off
            // IDが重複して認識すると上書きされるから、そこを治す
            VALUE marker_data = rb_ary_new_from_args(
                9,
                INT2NUM(markerIds[i]),
                rb_float_new(markerCorners[i][0].x),
                rb_float_new(markerCorners[i][0].y),
                rb_float_new(markerCorners[i][1].x),
                rb_float_new(markerCorners[i][1].y),
                rb_float_new(markerCorners[i][2].x), 
                rb_float_new(markerCorners[i][2].y),
                rb_float_new(markerCorners[i][3].x), 
                rb_float_new(markerCorners[i][3].y) 
            );
            // clang-format on

            rb_ary_push(arr,marker_data);
        }

        return arr;
    }

    static VALUE detect_wait(VALUE self,VALUE timeout)
    {
        cv::waitKey(NUM2INT(timeout));
        return Qnil;
    }

    extern "C"
    {
        extern void Init_opencv_aruco_detector(void)
        {
            VALUE mArucoDetector = rb_define_module("ArucoDetector");
            rb_define_singleton_method(mArucoDetector, "open", detect_open, 0);
            rb_define_singleton_method(mArucoDetector, "get", detect_get, 0);
            rb_define_singleton_method(mArucoDetector, "wait", detect_wait, 1);
        }
    }

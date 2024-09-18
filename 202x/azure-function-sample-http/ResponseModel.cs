using System;
using System.Collections.Generic;
using System.Text;

namespace azure_function_sample_http
{
    class ResponseModel
    {
        public bool Error { get; set; } = false;
        public string Message { get; set; }
        public int? Result { get; set; }
    }
}

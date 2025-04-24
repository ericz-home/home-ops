package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
)

type HassClient struct {
	Client *http.Client
	URL    string
}

func NewHass() *HassClient {
	return &HassClient{
		Client: http.DefaultClient,
		URL:    Config.HomeAssistantURL,
	}
}

type HassTarget struct {
	Type string `json:"type"`
	Name string `json:"name"`
	ID   string `json:"id"`
}

type HassData struct {
	Targets []HassTarget `json:"targets"`
	Success []HassTarget `json:"success"`
	Failed  []HassTarget `json:"failed"`
}

type ConversationRequest struct {
	Text           string `json:"text"`
	Language       string `json:"language"`
	Agent          string `json:"agent_id"`
	ConversationID string `json:"conversation_id,omitempty"`
}

type ConversationResponse struct {
	Data           HassData
	Speech         string
	ConversationID string
}

type ConversationError struct {
	Code   string
	Speech string
}

func (h *HassClient) Conversation(text, id, agent string) (*ConversationResponse, *ConversationError, error) {
	path := h.URL + "/api/conversation/process"
	req, err := generateRequest(path, text, id, agent)
	if err != nil {
		return nil, nil, err
	}

	resp, err := h.Client.Do(req)
	if err != nil {
		return nil, nil, err
	}

	return parseResponse(resp)
}

func parseError(resp *http.Response) error {
	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	slog.Error("received error from HomeAssistant", "code", resp.StatusCode, "body", string(b))
	return errors.New("error response from HomeAssistant")
}

func parseResponse(resp *http.Response) (*ConversationResponse, *ConversationError, error) {
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, nil, parseError(resp)
	}

	var r struct {
		Response struct {
			ResponseType         string                 `json:"response_type"`
			Data                 json.RawMessage        `json:"data"`
			Speech               map[string]interface{} `json:"speech"`
			Language             string                 `json:"language"`
			ConversationID       string                 `json:"conversation_id"`
			ContinueConversation bool                   `json:"continue_conversation"`
		} `json:"response"`
	}

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, nil, err
	}

	dec := json.NewDecoder(bytes.NewReader(b))
	if err := dec.Decode(&r); err != nil {
		return nil, nil, err
	}

	slog.Debug("received response from homeassistant", "r", r, "body", string(b))

	plain, ok := r.Response.Speech["plain"].(map[string]interface{})
	if !ok {
		slog.Error("couldn't parse plain speech", "speech", r.Response.Speech)
		return nil, nil, errors.New("couldn't parse JSON response")
	}
	speech, ok := plain["speech"].(string)
	if !ok {
		slog.Error("couldn't parse plain speech", "plain", plain)
		return nil, nil, errors.New("couldn't parse JSON response")
	}

	switch r.Response.ResponseType {
	case "action_done", "query_answer":
		var data HassData
		if err := json.Unmarshal(r.Response.Data, &data); err != nil {
			return nil, nil, err
		}

		return &ConversationResponse{data, speech, r.Response.ConversationID}, nil, nil
	case "error":
		var data struct {
			Code string `json:"code"`
		}
		if err := json.Unmarshal(r.Response.Data, &data); err != nil {
			return nil, nil, err
		}

		return nil, &ConversationError{data.Code, speech}, nil
	}

	slog.Error("unknown homeassistant response type", "type", r.Response.ResponseType, "response", r)
	return nil, nil, errors.New("unknown HomeAssistant response type")
}

func generateRequest(url, text, id, agent string) (*http.Request, error) {
	b := bytes.NewBuffer(nil)
	body := ConversationRequest{text, "en", agent, id}

	enc := json.NewEncoder(b)
	if err := enc.Encode(body); err != nil {
		return nil, err
	}

	req, err := http.NewRequest(http.MethodPost, url, b)
	if err != nil {
		return nil, err
	}

	req.Header.Add("ContentType", "application/json")
	req.Header.Add("Authorization", "Bearer "+Config.HomeAssistantToken)

	return req, nil
}
